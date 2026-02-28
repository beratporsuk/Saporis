//
//  PostService.swift
//  Saporis
//
//  Created by Berat PORSUK on 7.08.2025.
//import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage

final class PostService {
    static let shared = PostService()

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}

    // MARK: - Upload Post (single image)

    func uploadPost(
        userId: String,
        venueId: String,
        venueName: String,
        commentText: String,
        image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(
                domain: "PostService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Fotoğraf verisi okunamadı."]
            )))
            return
        }

        let postId = UUID().uuidString
        let fileId = UUID().uuidString
        let imageRef = storage.reference().child("posts/\(userId)/\(fileId).jpg")

        let md = StorageMetadata()
        md.contentType = "image/jpeg"

        imageRef.putData(imageData, metadata: md) { _, err in
            if let err = err {
                completion(.failure(err))
                return
            }

            imageRef.downloadURL { url, err in
                if let err = err {
                    completion(.failure(err))
                    return
                }
                guard let url = url else {
                    completion(.failure(NSError(
                        domain: "PostService",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "Download URL alınamadı."]
                    )))
                    return
                }

                let data: [String: Any] = [
                    "id": postId,
                    "userId": userId,
                    "venueId": venueId,
                    "venueName": venueName,
                    "commentText": commentText,
                    "imageURLs": [url.absoluteString],      // ✅ yeni alan (array)
                    "imageURL": url.absoluteString,         // ✅ geriye uyum
                    "timestamp": FieldValue.serverTimestamp()
                ]

                self.db.collection("posts").document(postId).setData(data) { err in
                    if let err = err { completion(.failure(err)) }
                    else { completion(.success(())) }
                }
            }
        }
    }

    // MARK: - Feed Posts
    // Şimdilik FollowService yoksa: sadece kullanıcının kendi postları gelir (compile garanti).
    // Sonra FollowService ekleyince "following + self" yaparız.

    func fetchFeedPosts(for userId: String, completion: @escaping ([PostModel]) -> Void) {
        // ✅ Fallback: FollowService yok -> sadece kendi postlarını getir
        fetchPosts(for: userId, completion: completion)
    }

    // MARK: - Last Post

    func fetchLastPost(for userId: String, completion: @escaping (PostModel?) -> Void) {
        db.collection("posts")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .getDocuments { snap, err in
                guard err == nil, let doc = snap?.documents.first else {
                    completion(nil)
                    return
                }
                completion(PostModel(data: doc.data(), id: doc.documentID))
            }
    }

    // MARK: - User Posts

    func fetchPosts(for userId: String, completion: @escaping ([PostModel]) -> Void) {
        db.collection("posts")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: 50)
            .getDocuments { snap, err in
                guard err == nil, let docs = snap?.documents else {
                    completion([])
                    return
                }
                completion(docs.compactMap { PostModel(data: $0.data(), id: $0.documentID) })
            }
    }

    func fetchAllPosts(for userId: String, completion: @escaping ([PostModel]) -> Void) {
        fetchPosts(for: userId, completion: completion)
    }
}
