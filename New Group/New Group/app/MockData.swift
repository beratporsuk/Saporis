//
//  MockData.swift
//  Saporis
//
//  Created by Berat PORSUK on 14.07.2025.
//

import Foundation

struct MockData {
    static let venues: [Venue] = [
        Venue(
            id: "1",
            name: "MOJE & MORE",
            city: "Ankara",
            latitude: 39.9208,
            longitude: 32.8541,
            category: "Kahve",
            rating: 4.8, isRecommended: false, wasRecommendedByAFriend: false, googlePlaceID: "1", address: "Angara"
           
        ),
        Venue(
            id: "2",
            name: "Latife Kafe",
            city: "İstanbul",
            latitude: 41.0082,
            longitude: 28.9784,
            category: "Tatlı",
            rating: 4.8, isRecommended: false, wasRecommendedByAFriend: false, googlePlaceID: "2", address: "Angara"
        ),
        Venue(
            id: "3",
            name: "Cafe des Cafes",
            city: "İzmir",
            latitude: 38.4192,
            longitude: 27.1287,
            category: "Pub",
            rating: 4.8, isRecommended: false, wasRecommendedByAFriend: false, googlePlaceID: "3", address: "Angara"
        ),
        Venue(
            id: "4",
            name: "Mangerie",
            city: "İstanbul",
            latitude: 41.0704,
            longitude: 29.0271,
            category: "Akşam Yemeği",
            rating: 4.8, isRecommended: false, wasRecommendedByAFriend: false, googlePlaceID: "4", address: "Angara"
        ),
        Venue(
            id: "5",
            name: "Fesleğen",
            city: "Ankara",
            latitude: 39.9334,
            longitude: 32.8597,
            category: "Kahvaltı",
            rating: 4.8, isRecommended: false, wasRecommendedByAFriend: false, googlePlaceID: "5", address: "Angara"
        )
    ]
}
