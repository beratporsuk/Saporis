//
//  MiniMapView.swift
//  Saporis
//
//  Created by Berat PORSUK on 15.07.2025.
//

import SwiftUI
import MapKit
import CoreLocation


struct MiniMapView: View {
    let venues: [Venue]

    @State private var showFullScreenMap = false
    @State private var selectedVenue: Venue? = nil
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(venues, id: \.id) { venue in
                Annotation(venue.name, coordinate: CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 5, height: 5)
                        .onTapGesture {
                            selectedVenue = venue
                            withAnimation {
                                cameraPosition = .region(
                                    MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude),
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    )
                                )
                            }
                        }
                }
            }
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            Group {
                if let selected = selectedVenue {
                    VStack {
                        Spacer()
                        HStack {
                            Text(selected.name)
                                .font(.caption)
                                .padding(8)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
        )
        .onTapGesture {
            showFullScreenMap = true
        }
        .sheet(isPresented: $showFullScreenMap) {
            FullScreenMapView(venues: venues)
        }
    }
}
