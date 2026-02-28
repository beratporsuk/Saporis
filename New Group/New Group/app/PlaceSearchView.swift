//
//  PlaceSearchView.swift
//  Saporis
//
//  Created by Berat PORSUK on 15.07.2025.
//

import SwiftUI
import CoreLocation

struct PlaceSearchView: View {
    @StateObject private var placesService = PlacesService()
    @State private var searchText = ""
    @State private var debounceTask: Task<Void, Never>?
    @State private var didRestoreState = false

    private let userLocation = CLLocationCoordinate2D(latitude: 39.9208, longitude: 32.8541)

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                HStack(spacing: 10) {
                    TextField("Bir yer ara (ör. Milano, Beşevler, Starbucks)", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .onChange(of: searchText) { _, newValue in
                            // 🔥 sadece kullanıcı yazınca değişsin
                            scheduleDebouncedSearch(newValue)
                        }

                    Button {
                        triggerSearch(searchText)
                    } label: {
                        Text("Ara").fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(searchText.trimmingCharacters(in: .whitespacesAndNewlines).count < 2)
                }
                .padding(.horizontal)

                if placesService.venues.isEmpty {
                    Spacer()
                    Text(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                         ? "Bir arama yaparak mekanları listeleyebilirsin."
                         : "Sonuç bulunamadı.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    List(placesService.venues) { venue in
                        // ✅ burada senin detay navigasyonun nasıl ise onu koyacağız.
                        // Şimdilik kart görünümü:
                        VStack(alignment: .leading, spacing: 4) {
                            Text(venue.name).font(.headline)
                            HStack(spacing: 10) {
                                Text("⭐️ \(venue.rating, specifier: "%.1f")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                if !venue.city.isEmpty {
                                    Text("📍 \(venue.city)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .listStyle(.plain)
                }
            }
            .padding(.top, 8)
            .navigationTitle("Mekan Ara")
            .onAppear {
                // ✅ Geri gelince aramayı tekrar tetikleme
                // Sadece state restore et
                guard !didRestoreState else { return }
                didRestoreState = true
                
                
                placesService.restoreIfNeeded()
                searchText = placesService.lastQuery


                // Eğer daha önce arama yaptıysan yazıyı geri getir
                if !placesService.lastQuery.isEmpty {
                    searchText = placesService.lastQuery
                }

                placesService.startSearchSession()
            }
            .onDisappear {
                placesService.endSearchSession()
            }
        }
    }

    private func scheduleDebouncedSearch(_ text: String) {
        debounceTask?.cancel()

        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if q.isEmpty {
            placesService.places = []
            placesService.venues = []
            placesService.lastQuery = ""
            return
        }

        guard q.count >= 2 else { return }

        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            if Task.isCancelled { return }
            triggerSearch(q)
        }
    }

    private func triggerSearch(_ text: String) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard q.count >= 2 else { return }
        placesService.fetchNearbyPlaces(query: q, location: userLocation)
    }
}
