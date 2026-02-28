//
//  FullScreenMapView.swift
//  Saporis
//
//  Created by Berat PORSUK on 15.07.2025.
//

import SwiftUI
import MapKit

struct FullScreenMapView: View {
    let venues: [Venue]

    @Environment(\.dismiss) var dismiss
    @State private var selectedVenue: Venue? = nil
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Map(position: $cameraPosition) {
                    ForEach(venues, id: \.id) { venue in
                        let coordinate = CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)
                        
                        Annotation(venue.name, coordinate: coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    selectedVenue = venue
                                    withAnimation {
                                        cameraPosition = .region(
                                            MKCoordinateRegion(
                                                center: coordinate,
                                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                            )
                                        )
                                    }
                                }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)

                // Seçilen mekan detayı
                if let venue = selectedVenue {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(venue.name)
                            .font(.headline)
                        Text(venue.category)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(venue.city)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding()
                    .transition(.move(edge: .top))
                }
            }
            .navigationTitle("Keşfedilen Yerler")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}
