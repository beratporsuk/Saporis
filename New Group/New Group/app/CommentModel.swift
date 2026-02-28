//
//  CommentModel.swift
//  Saporis
//
//  Created by Berat PORSUK on 14.07.2025.
//

import Foundation

struct Comment: Identifiable, Codable {
    var id: String = UUID().uuidString
    var userId: String
    var venueId: String
    var venueName: String
    var content: String
    var timestamp: Date
}
