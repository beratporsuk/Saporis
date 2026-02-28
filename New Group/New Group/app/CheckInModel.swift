//
//  CheckInModel.swift
//  Saporis
//
//  Created by Berat PORSUK on 14.07.2025.
//

import Foundation

struct CheckIn: Identifiable, Codable {
    var id: String = UUID().uuidString
    var userId: String
    var venueId: String
    var venueName: String
    var timestamp: Date
}
