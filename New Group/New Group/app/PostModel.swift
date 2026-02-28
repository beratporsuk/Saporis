//
//  PostModel.swift
//  Saporis
//
//  Created by Berat PORSUK on 7.08.2025.
//import Foundation
import FirebaseFirestore

struct PostModel: Identifiable, Hashable {
    let id: String

    let userId: String
    let venueId: String?
    let venueName: String
    let commentText: String
    let imageURLs: [String]
    let timestamp: Date

    var firstImageURL: URL? {
        guard let s = imageURLs.first, let u = URL(string: s) else { return nil }
        return u
    }

    init?(doc: QueryDocumentSnapshot) {
        self.init(data: doc.data(), id: doc.documentID)
    }

    init?(doc: DocumentSnapshot) {
        guard let data = doc.data() else { return nil }
        self.init(data: data, id: doc.documentID)
    }

    // ✅ TEK init(data:id:) burada olacak
    init?(data: [String: Any], id: String) {
        guard
            let userId = data["userId"] as? String,
            let venueName = data["venueName"] as? String,
            let commentText = data["commentText"] as? String
        else { return nil }

        let urls: [String]
        if let arr = data["imageURLs"] as? [String] {
            urls = arr
        } else if let single = data["imageURL"] as? String, !single.isEmpty {
            urls = [single]
        } else {
            urls = []
        }

        self.id = id
        self.userId = userId
        self.venueId = data["venueId"] as? String
        self.venueName = venueName
        self.commentText = commentText
        self.imageURLs = urls
        self.timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? .distantPast
    }
}
