//
//  NotificationModel.swift
//  Saporis
//
//  Created by Berat PORSUK on 7.08.2025.
//

import Foundation
import FirebaseFirestore

struct NotificationModel: Identifiable {
    let id: String
    let toUserId: String
    let fromUserId: String
    let type: String
    let venueName: String?
    let timestamp: Date
    let isRead: Bool
    
    init?(document: [String: Any], id: String) {
        self.id = id
        self.toUserId = document["toUserId"] as? String ?? ""
        self.fromUserId = document["fromUserId"] as? String ?? ""
        self.type = document["type"] as? String ?? ""
        self.venueName = document["venueName"] as? String
        self.timestamp = (document["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        self.isRead = document["isRead"] as? Bool ?? false
    }
}

