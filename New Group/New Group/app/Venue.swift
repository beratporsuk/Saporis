//
//  Venue.swift
//  Saporis
//
//  Created by Berat PORSUK on 16.07.2025.
//
import Foundation
import CoreLocation

struct Venue: Identifiable, Codable {
    var id: String        // Google'dan gelen place_id
    var name: String
    var city: String
    var latitude: Double
    var longitude: Double
    var category: String
    var rating: Double
    var photoURL: String?
    var userRatingsTotal: Int?

    // Firebase için uygulamaya özel alanlar
    var isRecommended: Bool
    var wasRecommendedByAFriend: Bool
    let googlePlaceID: String
    
    var address: String
}


extension Venue {
    init(from place: GooglePlace) {
        self.id = place.place_id
        self.name = place.name
        self.city = place.formatted_address ?? "Bilinmeyen"
        self.latitude = place.geometry.location.lat
        self.longitude = place.geometry.location.lng
        self.category = place.types?.first ?? "Genel"
        self.rating = place.rating ?? 0
        self.photoURL = place.getPhotoURLs().first
        self.userRatingsTotal = place.user_ratings_total
        self.isRecommended = false
        self.wasRecommendedByAFriend = place.wasRecommendedByAFriend
        self.googlePlaceID = place.place_id
       
            
        
        self.id = UUID().uuidString
        self.address = place.formatted_address ?? "Adres yok"


    }
}
