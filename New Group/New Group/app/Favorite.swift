//
//  Favorite.swift
//  Saporis
//
//  Created by Berat PORSUK on 15.07.2025.
//

import Foundation

struct Favorite: Identifiable, Codable {
    var id: String = UUID().uuidString
    var userId: String
    var venueId: String
    var venueName: String
    var timestamp: Date
}

