//
//  NotificationService.swift
//  Saporis
//
//  Created by Berat PORSUK on 7.08.2025.
//

import Foundation
import FirebaseFirestore

class NotificationService {
    static let shared = NotificationService()
    private let db = Firestore.firestore()

    private init() {}

    func fetchNotifications(for userId: String, completion: @escaping ([NotificationModel]) -> Void) {
        db.collection("notifications")
            .whereField("toUserId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else {
                    print("Bildirim alınamadı: \(error?.localizedDescription ?? "Bilinmeyen hata")")
                    completion([])
                    return
                }
                
                let notifications = docs.compactMap {
                    NotificationModel(document: $0.data(), id: $0.documentID)
                }
                completion(notifications)
            }
    }
}
