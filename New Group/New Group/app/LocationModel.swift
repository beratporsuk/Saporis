//
//  LocationModel.swift
//  Saporis
//
//  Created by Berat PORSUK on 15.07.2025.
//

import CoreLocation

struct LocationModel: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: LocationModel, rhs: LocationModel) -> Bool {
        return lhs.name == rhs.name &&
               lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}
