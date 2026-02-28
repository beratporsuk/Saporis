//
//  MapView.swift
//  Saporis
//
//  Created by Berat PORSUK on 15.07.2025.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    
    // Konum bölgesi için state
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.925533, longitude: 32.866287), // Ankara varsayılan
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
           )
    )

    var body: some View {
        Map(position: $cameraPosition) {
            if let userLocation = locationManager.userLocation {
                // Kullanıcı konumuna pin ekleyelim (opsiyonel)
                Annotation("Senin Konumun", coordinate: userLocation) {
                    Image(systemName: "location.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
        }
        .onReceive(locationManager.$userLocation) { newLocation in
            if let newLocation = newLocation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                    center: newLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
           )
        }
        }
        .edgesIgnoringSafeArea(.all)
    }
}


