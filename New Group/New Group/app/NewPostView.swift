//
//  NewPostView.swift
//  Saporis
//
//  Created by Berat PORSUK on 7.08.2025.
//
/*
import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class PostService {
    static let shared = PostService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private init() {}

    /// Tek fotoğraf + yorum + mekan bilgisiyle post yükler
    func uploadPost(
        userId: String,
        venueId: String,
        venueName: String,
        commentText: String,
        image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Görseli küçült → jpeg data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "PostService", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Görsel dönüştürülemedi."])))
            return
        }

        // Storage yolu: posts/{uid}/{uuid}.jpg
        let imageId = UUID().uuidString
        let ref = storage.reference().child("posts/\(userId)/\(imageId).jpg")

        // Storage’a yükle
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Download URL al
            ref.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let url = url else {
                    completion(.failure(NSError(domain: "PostService", code: -2,
                                                userInfo: [NSLocalizedDescriptionKey: "Download URL alınamadı."])))
                    return
                }

                // Firestore’a yazılacak veri
                let postId = UUID().uuidString
                let postData: [String: Any] = [
                    "id": postId,
                    "userId": userId,
                    "venueId": venueId,
                    "venueName": venueName,
                    "commentText": commentText,
                    "imageURLs": [url.absoluteString],   // tek fotoğraf da olsa dizi olarak tut
                    "timestamp": FieldValue.serverTimestamp()
                ]

                self.db.collection("posts").document(postId).setData(postData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
}*/
