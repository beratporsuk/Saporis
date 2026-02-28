//
//  MapKit.swift
//  Saporis
//
//  Created by Berat PORSUK on 15.07.2025.
//

import MapKit

func openInMaps(latitude: CLLocationDegrees, longitude: CLLocationDegrees, placeName: String) {
    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

    let placemark = MKPlacemark(coordinate: coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = placeName

    mapItem.openInMaps(launchOptions: [
        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
    ])
}
