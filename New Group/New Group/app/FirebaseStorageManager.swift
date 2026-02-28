//
//  FirebaseStorageManager.swift
//  Saporis
//
//  Created by Berat PORSUK on 6.07.2025.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

final class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    private let storage = Storage.storage()
    private init() {}

    // MARK: - Helpers

    /// Görseli uzun kenarı maxDimension olacak şekilde küçültür ve JPEG data üretir.
    private func resizedJPEGData(from image: UIImage, maxDimension: CGFloat = 1440, quality: CGFloat = 0.8) -> Data? {
        let size = image.size
        let scale = min(maxDimension / max(size.width, size.height), 1.0)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized?.jpegData(compressionQuality: quality)
    }

    /// Storage metadata (contentType + opsiyonel cache-control)
    private func imageMetadata() -> StorageMetadata {
        let md = StorageMetadata()
        md.contentType = "image/jpeg"
        md.cacheControl = "public, max-age=604800" // 7 gün
        return md
    }

    // MARK: - Profile Image (Completion-style, mevcut kullanımın bozulmasın)

    /// Profil fotoğrafını Storage'a yükler, download URL döner (completion).
    func uploadProfileImage(_ image: UIImage, for uid: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = resizedJPEGData(from: image, maxDimension: 1024, quality: 0.82) else {
            let error = NSError(domain: "FirebaseStorageManager", code: 1001,
                                userInfo: [NSLocalizedDescriptionKey: "Görsel verisi dönüştürülemedi."])
            completion(.failure(error))
            return
        }

        let path = "profile_images/\(uid).jpg" // Storage rules buna göre olmalı
        let ref = storage.reference().child(path)

        ref.putData(imageData, metadata: imageMetadata()) { _, error in
            if let error = error { completion(.failure(error)); return }
            ref.downloadURL { url, err in
                if let err = err { completion(.failure(err)); return }
                guard let url = url else {
                    let e = NSError(domain: "FirebaseStorageManager", code: 1002,
                                    userInfo: [NSLocalizedDescriptionKey: "Download URL alınamadı."])
                    completion(.failure(e)); return
                }
                completion(.success(url))
            }
        }
    }

    // MARK: - Profile Image (Async/Await sürüm)

    func uploadProfileImageAsync(_ image: UIImage, for uid: String) async throws -> URL {
        guard let imageData = resizedJPEGData(from: image, maxDimension: 1024, quality: 0.82) else {
            throw NSError(domain: "FirebaseStorageManager", code: 1001,
                          userInfo: [NSLocalizedDescriptionKey: "Görsel verisi dönüştürülemedi."])
        }
        let ref = storage.reference().child("profile_images/\(uid).jpg")
        _ = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<StorageMetadata, Error>) in
            ref.putData(imageData, metadata: imageMetadata()) { md, err in
                if let err = err { cont.resume(throwing: err) } else { cont.resume(returning: md!) }
            }
        }
        let url: URL = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<URL, Error>) in
            ref.downloadURL { url, err in
                if let err = err { cont.resume(throwing: err) }
                else if let url = url { cont.resume(returning: url) }
                else {
                    cont.resume(throwing: NSError(domain: "FirebaseStorageManager", code: 1002,
                                                  userInfo: [NSLocalizedDescriptionKey: "Download URL alınamadı."]))
                }
            }
        }
        return url
    }

    /// Eski profil görselini silmek istersen:
    func deleteProfileImage(uid: String) async throws {
        let ref = storage.reference().child("profile_images/\(uid).jpg")
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            ref.delete { err in
                if let err = err { cont.resume(throwing: err) } else { cont.resume() }
            }
        }
    }

    // MARK: - Post / Check-in Görselleri

    /// Çoklu görsel yükler, download URL dizisi döner. Yol: posts/{userId}/{uuid}.jpg
    func uploadPostImages(userId: String, imagesData: [Data]) async throws -> [String] {
        var urls: [String] = []
        for (idx, data) in imagesData.enumerated() {
            let fileName = "posts/\(userId)/\(UUID().uuidString)_\(idx).jpg"
            let ref = storage.reference().child(fileName)

            // Metadata ile yükle
            _ = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<StorageMetadata, Error>) in
                ref.putData(data, metadata: imageMetadata()) { md, err in
                    if let err = err { cont.resume(throwing: err) } else { cont.resume(returning: md!) }
                }
            }

            let url: URL = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<URL, Error>) in
                ref.downloadURL { url, err in
                    if let err = err { cont.resume(throwing: err) }
                    else if let url = url { cont.resume(returning: url) }
                    else {
                        cont.resume(throwing: NSError(domain: "FirebaseStorageManager", code: 1003,
                                                      userInfo: [NSLocalizedDescriptionKey: "Download URL alınamadı."]))
                    }
                }
            }
            urls.append(url.absoluteString)
        }
        return urls
    }

    /// UIImage dizisini kendisi küçültüp yüklesin istersen:
    func uploadPostImages(userId: String, uiImages: [UIImage]) async throws -> [String] {
        let datas: [Data] = uiImages.compactMap { resizedJPEGData(from: $0, maxDimension: 1440, quality: 0.8) }
        return try await uploadPostImages(userId: userId, imagesData: datas)
    }
}
