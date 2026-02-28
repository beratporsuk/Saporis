//
//  GooglePlace.swift
//  Saporis
//
//  Created by Berat PORSUK on 16.07.2025.
//
import Foundation
import CoreLocation

struct GooglePlace: Codable, Identifiable, Hashable {
    //  Google tarafından verilen benzersiz ID
    let place_id: String
    var id: String { place_id }

    let name: String
    let formatted_address: String?
    
    var rating: Double?
    var user_ratings_total: Int?
    let types: [String]?
    let price_level: Int?
    let opening_hours: OpeningHours?
    let geometry: Geometry
    let photos: [Photo]?
    let website: String?
    var reviews: [GoogleReview]?
    let vicinity: String?


    // MARK: - Özelleştirilmiş Alanlar

    var cleanedAddress: String? {
        let components = formatted_address?.components(separatedBy: ",") ?? []
        let trimmed = components.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        let filtered = trimmed.filter { part in
            let lower = part.lowercased()
            if lower.contains("türkiye") { return false }
            if part.range(of: #"^\d{7}$"#, options: .regularExpression) != nil { return false }
            if lower.contains("no:") { return false }
            if part.range(of: #"\d{4,5}"#, options: .regularExpression) != nil && part.contains("No:") { return false }
            return true
        }

        let simplified = filtered.suffix(2).joined(separator: " / ")
        return simplified.isEmpty ? nil : simplified
    }

    var formattedPriceLevel: String? {
        guard let level = price_level else { return nil }
        switch level {
        case 0: return "₺0–150"
        case 1: return "₺150-300"
        case 2: return "₺300–500"
        case 3: return "₺500-1000"
        case 4: return "₺1000+"
        default: return nil
        }
    }

    func getPhotoURLs(maxWidth: Int = 600) -> [String] {
        guard let photos = photos else { return [] }
       // let apiKey = "AIzaSyDvEUbINVDZPeXNx8QbFBDw1Dls2zlU208"
        return photos.map { ref in
            "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&photoreference=\(ref.photo_reference)&key=AIzaSyDvEUbINVDZPeXNx8QbFBDw1Dls2zlU208"
        }
    }

    func getLocation() -> CLLocation {
        CLLocation(latitude: geometry.location.lat, longitude: geometry.location.lng)
    }

    var wasRecommendedByAFriend: Bool {
        return Bool.random()
    }

    // MARK: - İç Modeller
    struct OpeningHours: Codable, Hashable {
        let open_now: Bool?
        let weekday_text: [String]?
    }

    struct Geometry: Codable, Hashable {
        let location: Location
    }

    struct Location: Codable, Hashable {
        let lat: Double
        let lng: Double
    }

    struct Photo: Codable, Hashable {
        let photo_reference: String
    }
    var address: String {
            return vicinity ?? ""
        }
    
    
    struct GoogleReview: Codable, Identifiable, Hashable {
        var id: String { text + relativeTimeDescription }
        let text: String
        let rating: Int
        let relativeTimeDescription: String

        enum CodingKeys: String, CodingKey {
            case text
            case rating
            case relativeTimeDescription = "relative_time_description"
        }
    }

}
