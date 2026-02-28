//
//  PlacesService.swift
//  Saporis
//
//  Created by Berat PORSUK on 15.07.2025.
//import Foundation
import CoreLocation

// MARK: - Text Search response
struct GooglePlacesResponse: Codable {
    let results: [GooglePlace]
}

// MARK: - Details response
private struct GooglePlaceDetailResponse: Codable {
    let result: GooglePlace
}

// MARK: - Basit URLSession seçimi
private let URLS: URLSession = {
    return Net.session
}()

// MARK: - Arama cache anahtarı: sorgu + yaklaşık konum kovası
private struct SearchKey: Hashable {
    let q: String
    let latBucket: Int
    let lonBucket: Int
    let filtersSig: Int

    static func make(query: String, loc: CLLocationCoordinate2D?, filtersSig: Int = 0) -> SearchKey {
        // ~300 m kovası (0.003° ≈ 300 m)
        let latB = Int(((loc?.latitude  ?? 0) / 0.003).rounded())
        let lonB = Int(((loc?.longitude ?? 0) / 0.003).rounded())
        return SearchKey(
            q: query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
            latBucket: latB,
            lonBucket: lonB,
            filtersSig: filtersSig
        )
    }
}

// MARK: - Mekan Servisi
final class PlacesService: ObservableObject {

    enum SearchMode: String, Codable {
        case global
        case local
    }

    // UI’ya yayınlanan veriler
    @Published var venues: [Venue] = []
    @Published var places: [GooglePlace] = []
    @Published var selectedPlace: GooglePlace?

    // ✅ Son arama state’i (geri dönünce kaldığın yer)
    @Published var lastQuery: String = ""
    @Published var lastMode: SearchMode = .local
    @Published var hasActiveResults: Bool = false

    // Debug sayaçları
    private var listCount = 0
    private var detailsCount = 0
    private var reviewsCount = 0

    // Cache + rate limit
    private let listCache   = TTLCache<SearchKey, [GooglePlace]>(capacity: 120) // 45 dk
    private let detailCache = TTLCache<String, GooglePlace>(capacity: 200)      // 6 saat
    private let limiter     = RateLimiter(minInterval: 0.25)                    // 250 ms

    // Autocomplete session token
    private var sessionToken: String?

    func startSearchSession() { sessionToken = UUID().uuidString }
    func endSearchSession()   { sessionToken = nil }

    /// ✅ Geri dönünce (view yeniden çizilse bile) sonuçları bozma.
    /// Bu fonksiyon fetch yapmaz; sadece state varsa UI’yı aynı bırakır.
    func restoreIfNeeded() {
        // venues zaten doluysa dokunma
        if !venues.isEmpty || !places.isEmpty {
            hasActiveResults = true
            return
        }
        // Eğer geçmişte query vardı ama liste boşsa, UI'da text restore edilecek
        hasActiveResults = false
    }

    // MARK: - Ana Arama
    /// Kullanıcı lokasyon yazarsa global arama yapar (Milano, Beşevler vb.)
    /// Kullanıcı mekan adı yazarsa yakın çevrede arar (Starbucks, Kakule vb.)
    func fetchNearbyPlaces(query: String, location: CLLocationCoordinate2D) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // ✅ Son query’yi sakla (detaydan dönünce input aynı kalsın)
        self.lastQuery = trimmed

        guard trimmed.count >= 2 else {
            DispatchQueue.main.async {
                self.places = []
                self.venues = []
                self.hasActiveResults = false
            }
            return
        }

        guard limiter.canFire() else { return }

        // API key
        guard let apiKey = Bundle.main.infoDictionary?["GooglePlacesAPIKey"] as? String, !apiKey.isEmpty else {
            print("❌ GooglePlacesAPIKey bulunamadı (Info.plist).")
            return
        }

        let isLocationLike = looksLikeLocationQuery(trimmed)
        self.lastMode = isLocationLike ? .global : .local

        // Cache key: global arama için loc = nil, local için loc = location
        let cacheKey = SearchKey.make(
            query: cacheQueryKey(for: trimmed, isLocationLike: isLocationLike),
            loc: isLocationLike ? nil : location
        )

        if let cached = listCache.get(cacheKey) {
            self.listCount += 1
            print("LIST (cache) calls:", self.listCount)

            DispatchQueue.main.async {
                self.places = cached
                self.venues = cached.map { Venue(from: $0) }
                self.hasActiveResults = !cached.isEmpty
            }
            return
        }

        // GLOBAL: "cafe in Milano"
        // LOCAL: location + radius
        let searchQuery: String
        let urlString: String

        if isLocationLike {
            searchQuery = "cafe in \(trimmed)"
            let encodedQ = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(encodedQ)&key=\(apiKey)"
        } else {
            searchQuery = trimmed
            let encodedQ = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(encodedQ)&location=\(location.latitude),\(location.longitude)&radius=50000&key=\(apiKey)"
        }

        guard let url = URL(string: urlString) else {
            print("❌ URL oluşturulamadı.")
            return
        }

        URLS.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Places API error:", error)
                return
            }
            guard let data else {
                print("❌ Places API: Veri alınamadı.")
                return
            }

            if let http = response as? HTTPURLResponse {
                #if DEBUG
                print("✅ Places HTTP:", http.statusCode, "| mode:", isLocationLike ? "GLOBAL" : "LOCAL", "| q:", searchQuery)
                #endif
            }

            do {
                let decoded = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)

                let allowedTypes: Set<String> = [
                    "restaurant", "cafe", "bar", "bakery",
                    "meal_takeaway", "meal_delivery", "night_club",
                    "shopping_mall"
                ]

                let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

                let filtered = decoded.results.filter { place in
                    guard let types = place.types else { return true }
                    return types.contains(where: { allowedTypes.contains($0) })
                }

                let sorted: [GooglePlace]
                if isLocationLike {
                    sorted = filtered // global aramada relevance bozulmasın
                } else {
                    sorted = filtered.sorted { p1, p2 in
                        let l1 = CLLocation(latitude: p1.geometry.location.lat, longitude: p1.geometry.location.lng)
                        let l2 = CLLocation(latitude: p2.geometry.location.lat, longitude: p2.geometry.location.lng)
                        return userLocation.distance(from: l1) < userLocation.distance(from: l2)
                    }
                }

                self.listCache.set(sorted, for: cacheKey, ttl: 45 * 60)

                DispatchQueue.main.async {
                    self.places = sorted
                    self.venues = sorted.map { Venue(from: $0) }
                    self.hasActiveResults = !sorted.isEmpty
                    #if DEBUG
                    print("Gelen sonuç:", decoded.results.count, "| filtre:", filtered.count, "| final:", sorted.count)
                    #endif
                }

            } catch {
                print("❌ JSON parse hatası:", error)
                print("HAM:", String(data: data, encoding: .utf8) ?? "boş veri")
            }

        }.resume()
    }

    // MARK: - Detaylar
    func fetchPlaceDetails(placeID: String, completion: ((GooglePlace?) -> Void)? = nil) {
        if let cached = detailCache.get(placeID) {
            self.detailsCount += 1
            print("DETAIL (cache) calls:", self.detailsCount)

            DispatchQueue.main.async {
                self.selectedPlace = cached
                completion?(cached)
            }
            return
        }

        guard limiter.canFire() else { return }
        guard let apiKey = Bundle.main.infoDictionary?["GooglePlacesAPIKey"] as? String, !apiKey.isEmpty else {
            print("❌ API anahtarı bulunamadı.")
            return
        }

        let fields = "place_id,name,formatted_address,geometry,photos,website,rating,user_ratings_total,price_level,opening_hours/weekday_text,types"
        let tokenPart = (sessionToken != nil) ? "&sessiontoken=\(sessionToken!)" : ""
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&fields=\(fields)&key=\(apiKey)\(tokenPart)"

        guard let url = URL(string: urlString) else {
            print("❌ Detay URL oluşturulamadı.")
            return
        }

        URLS.dataTask(with: url) { data, _, error in
            if let error {
                print("❌ Detay API hatası:", error)
                return
            }
            guard let data else {
                print("❌ Detay verisi alınamadı.")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(GooglePlaceDetailResponse.self, from: data)
                let place = decoded.result

                self.detailCache.set(place, for: placeID, ttl: 6 * 60 * 60)

                DispatchQueue.main.async {
                    self.selectedPlace = place
                    #if DEBUG
                    print("DETAY • foto:", place.photos?.count ?? 0)
                    #endif
                    completion?(place)
                }

            } catch {
                print("❌ Detay JSON parse hatası:", error)
                print("HAM:", String(data: data, encoding: .utf8) ?? "boş veri")
                completion?(nil)
            }
        }.resume()
    }

    // MARK: - Reviews (opsiyonel)
    func fetchPlaceReviews(placeID: String, completion: ((GooglePlace?) -> Void)? = nil) {
        guard limiter.canFire() else { return }
        guard let apiKey = Bundle.main.infoDictionary?["GooglePlacesAPIKey"] as? String, !apiKey.isEmpty else {
            print("❌ API anahtarı bulunamadı.")
            completion?(nil)
            return
        }

        let fields = "place_id,reviews,rating,user_ratings_total"
        let tokenPart = (sessionToken != nil) ? "&sessiontoken=\(sessionToken!)" : ""
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&fields=\(fields)&key=\(apiKey)\(tokenPart)"

        guard let url = URL(string: urlString) else {
            print("❌ Reviews URL oluşturulamadı.")
            completion?(nil)
            return
        }

        URLS.dataTask(with: url) { data, _, error in
            if let error {
                print("❌ Reviews API hatası:", error)
                completion?(nil)
                return
            }
            guard let data else {
                print("❌ Reviews verisi alınamadı.")
                completion?(nil)
                return
            }

            do {
                let decoded = try JSONDecoder().decode(GooglePlaceDetailResponse.self, from: data)
                let reviewsPlace = decoded.result

                var merged = reviewsPlace
                if let cached = self.detailCache.get(placeID) {
                    var copy = cached
                    copy.reviews = reviewsPlace.reviews
                    copy.user_ratings_total = reviewsPlace.user_ratings_total ?? copy.user_ratings_total
                    copy.rating = reviewsPlace.rating ?? copy.rating
                    merged = copy
                }

                self.detailCache.set(merged, for: placeID, ttl: 6 * 60 * 60)

                self.reviewsCount += 1
                print("REVIEWS calls:", self.reviewsCount)

                DispatchQueue.main.async {
                    self.selectedPlace = merged
                    completion?(merged)
                }

            } catch {
                print("❌ Reviews JSON parse hatası:", error)
                completion?(nil)
            }
        }.resume()
    }

    // MARK: - Helpers

    private func looksLikeLocationQuery(_ q: String) -> Bool {
        let lower = q.lowercased()

        let placeWords = ["cafe", "kahve", "restaurant", "restoran", "bar", "pub", "pizza", "burger", "starbucks", "kaf", "coffee"]
        if placeWords.contains(where: { lower.contains($0) }) { return false }

        let parts = lower.split(separator: " ")
        if parts.count >= 4 { return false }

        if lower.rangeOfCharacter(from: .decimalDigits) != nil { return false }

        return true
    }

    private func cacheQueryKey(for q: String, isLocationLike: Bool) -> String {
        if isLocationLike { return "GLOBAL::cafe in \(q)" }
        return "LOCAL::\(q)"
    }
}
