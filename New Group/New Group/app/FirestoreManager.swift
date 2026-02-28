//
//  FirestoreManager.swift
//  Saporis
//
//  Created by Berat PORSUK on 14.07.2025.
//
/*
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Firebase
import FirebaseStorage



func performCheckIn(for venue: Venue, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let userId = Auth.auth().currentUser?.uid else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturum açmamış."])))
        return
    }
    
    let checkIn = CheckIn(
        userId: userId,
        venueId: venue.id,
        venueName: venue.name,
        timestamp: Date()
    )
    
    do {
        try Firestore.firestore()
            .collection("checkins")
            .document(checkIn.id)
            .setData(from: checkIn) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    } catch {
        completion(.failure(error))
    }
}


// MARK: - Yorum Ekleme
func submitComment(for venue: Venue, content: String, rating: Int, imageData: Data? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let user = Auth.auth().currentUser else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu açık değil."])))
        return
    }

    let commentId = UUID().uuidString
    let commentRef = Firestore.firestore().collection("comments").document(commentId)

    var commentData: [String: Any] = [
        "id": commentId,
        "venueId": venue.id,
        "userId": user.uid,
        "rating": rating,
        "comment": content,
        "timestamp": Timestamp(date: Date())
    ]

    if let imageData = imageData {
        let storageRef = Storage.storage().reference().child("comment_images/\(commentId).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let url = url {
                    commentData["imageURL"] = url.absoluteString
                }
                commentRef.setData(commentData) { error in
                    completion(error == nil ? .success(()) : .failure(error!))
                }
            }
        }
    } else {
        commentRef.setData(commentData) { error in
            completion(error == nil ? .success(()) : .failure(error!))
        }
    }
}

/*func submitComment(for venue: Venue, content: String, imageData: Data? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let userID = Auth.auth().currentUser?.uid else {
        completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturum açmamış."])))
        return
    }

    let commentID = UUID().uuidString
    var commentData: [String: Any] = [
        "id": commentID,
        "userId": userID,
        "venueId": venue.id,
        "venueName": venue.name,
        "content": content,
        "timestamp": Timestamp(date: Date())
    ]

    let db = Firestore.firestore()
    let commentRef = db.collection("comments").document(commentID)

    // MARK: Fotoğraf varsa önce yükle
    if let imageData = imageData {
        let storageRef = Storage.storage().reference().child("commentImages/\(commentID).jpg")

        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let imageURL = url?.absoluteString {
                    commentData["imageURL"] = imageURL
                }

                commentRef.setData(commentData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }

    } else {
        // Fotoğraf yoksa direkt Firestore'a yorum ekle
        commentRef.setData(commentData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

*/
func addVenueToFavorites(_ venue: Venue, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let userId = Auth.auth().currentUser?.uid else {
        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı giriş yapmamış."])))
        return
    }

    let favorite = Favorite(
        userId: userId,
        venueId: venue.id,
        venueName: venue.name,
        timestamp: Date()
    )

    let db = Firestore.firestore()
    do {
        try db.collection("favorites")
            .document(favorite.id)
            .setData(from: favorite, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    } catch {
        completion(.failure(error))
    }
}
func fetchUserCheckIns(userId: String, completion: @escaping ([CheckIn]) -> Void) {
    let db = Firestore.firestore()
    db.collection("checkins")
        .whereField("userId", isEqualTo: userId)
        .order(by: "timestamp", descending: true)
        .getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                let checkIns = documents.compactMap { try? $0.data(as: CheckIn.self) }
                completion(checkIns)
            } else {
                completion([])
            }
        }
}
func fetchUserComments(userId: String, completion: @escaping ([Comment]) -> Void) {
    let db = Firestore.firestore()
    db.collection("comments")
        .whereField("userId", isEqualTo: userId)
        .order(by: "timestamp", descending: true)
        .getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                let comments = documents.compactMap { try? $0.data(as: Comment.self) }
                completion(comments)
            } else {
                completion([])
            }
        }
}
func fetchUserFavorites(userId: String, completion: @escaping ([Favorite]) -> Void) {
    let db = Firestore.firestore()
    db.collection("favorites")
        .whereField("userId", isEqualTo: userId)
        .order(by: "timestamp", descending: true)
        .getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                let favorites = documents.compactMap { try? $0.data(as: Favorite.self) }
                completion(favorites)
            } else {
                completion([])
            }
        }
}
*/

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// MARK: - Errors
enum SocialError: LocalizedError {
    case notSignedIn
    case imageEncodeFailed
    case unknown
    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "Kullanıcı oturum açmamış."
        case .imageEncodeFailed: return "Görsel verisi oluşturulamadı."
        case .unknown: return "Bilinmeyen bir hata oluştu."
        }
    }
}

// MARK: - Helpers
@inline(__always)
private func requireUID() throws -> String {
    guard let uid = Auth.auth().currentUser?.uid else { throw SocialError.notSignedIn }
    return uid
}

private func jpegData(_ image: UIImage, maxDimension: CGFloat = 1440, quality: CGFloat = 0.82) -> Data? {
    let size = image.size
    let scale = min(maxDimension / max(size.width, size.height), 1.0)
    let newSize = CGSize(width: size.width * scale, height: size.height * scale)
    UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
    image.draw(in: CGRect(origin: .zero, size: newSize))
    let resized = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resized?.jpegData(compressionQuality: quality)
}

private func imageMetadata() -> StorageMetadata {
    let md = StorageMetadata()
    md.contentType = "image/jpeg"
    md.cacheControl = "public, max-age=604800"
    return md
}

// MARK: - SocialActions
final class SocialActions {
    static let shared = SocialActions()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}

    // =========================
    // 1) CHECK-IN
    // =========================
    /// Check-in kaydı (serverTimestamp ile)
    func performCheckIn(venueId: String, venueName: String) async throws {
        let uid = try requireUID()
        let checkinId = UUID().uuidString
        let data: [String: Any] = [
            "id": checkinId,
            "userId": uid,
            "venueId": venueId,
            "venueName": venueName,
            "timestamp": FieldValue.serverTimestamp()
        ]
        try await db.collection("checkins").document(checkinId).setData(data)
    }

    /// Completion isteyen eski çağrılar için köprü
    func performCheckIn(for venue: Venue, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await performCheckIn(venueId: venue.id, venueName: venue.name)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // =========================
    // 2) YORUM (opsiyonel görselli)
    // =========================
    func submitComment(venueId: String,
                       venueName: String,
                       content: String,
                       rating: Int,
                       image: UIImage? = nil) async throws {
        let uid = try requireUID()
        let commentId = UUID().uuidString
        var data: [String: Any] = [
            "id": commentId,
            "venueId": venueId,
            "userId": uid,
            "rating": rating,
            "comment": content,
            "timestamp": FieldValue.serverTimestamp()
        ]

        if let image = image {
            guard let d = jpegData(image, maxDimension: 1440, quality: 0.82) else { throw SocialError.imageEncodeFailed }
            let ref = storage.reference().child("comment_images/\(commentId).jpg")
            _ = try await ref.putDataAsync(d, metadata: imageMetadata())
            let url = try await ref.downloadURL()
            data["imageURL"] = url.absoluteString
        }

        try await db.collection("comments").document(commentId).setData(data)
    }

    /// Completion köprüsü (senin imzanla uyumlu)
    func submitComment(for venue: Venue,
                       content: String,
                       rating: Int,
                       imageData: Data? = nil,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                var ui: UIImage? = nil
                if let imageData, let img = UIImage(data: imageData) { ui = img }
                try await submitComment(venueId: venue.id,
                                        venueName: venue.name,
                                        content: content,
                                        rating: rating,
                                        image: ui)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // =========================
    // 3) FAVORİYE EKLE
    // =========================
    func addVenueToFavorites(venueId: String, venueName: String) async throws {
        let uid = try requireUID()
        let id = UUID().uuidString
        let data: [String: Any] = [
            "id": id,
            "userId": uid,
            "venueId": venueId,
            "venueName": venueName,
            "timestamp": FieldValue.serverTimestamp()
        ]
        try await db.collection("favorites").document(id).setData(data, merge: true)
    }

    func addVenueToFavorites(_ venue: Venue, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await addVenueToFavorites(venueId: venue.id, venueName: venue.name)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // =========================
    // 4) LİSTELEME (profil sayfaları)
    // =========================
    func fetchUserCheckIns(userId: String) async -> [CheckIn] {
        do {
            let snap = try await db.collection("checkins")
                .whereField("userId", isEqualTo: userId)
                .order(by: "timestamp", descending: true)
                .getDocuments()
            return snap.documents.compactMap { try? $0.data(as: CheckIn.self) }
        } catch { return [] }
    }

    func fetchUserComments(userId: String) async -> [Comment] {
        do {
            let snap = try await db.collection("comments")
                .whereField("userId", isEqualTo: userId)
                .order(by: "timestamp", descending: true)
                .getDocuments()
            return snap.documents.compactMap { try? $0.data(as: Comment.self) }
        } catch { return [] }
    }

    func fetchUserFavorites(userId: String) async -> [Favorite] {
        do {
            let snap = try await db.collection("favorites")
                .whereField("userId", isEqualTo: userId)
                .order(by: "timestamp", descending: true)
                .getDocuments()
            return snap.documents.compactMap { try? $0.data(as: Favorite.self) }
        } catch { return [] }
    }
}




