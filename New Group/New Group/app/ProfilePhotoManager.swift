//
//  ProfilePhotoManager.swift
//  Saporis
//
//  Created by Berat PORSUK on 6.07.2025.
//

import SwiftUI
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class ProfilePhotoManager: ObservableObject {
    static let shared = ProfilePhotoManager()
    
    @Published var imageURL: URL? = nil
    
    private init() {}

    // Profil fotoğrafını Firebase'e yükler, Firestore'a URL'yi kaydeder, completion ile URL döner
    func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "ProfilePhotoManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu bulunamadı."])
            completion(.failure(error))
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            let error = NSError(domain: "ProfilePhotoManager", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Görsel verisi dönüştürülemedi."])
            completion(.failure(error))
            return
        }

        let storageRef = Storage.storage().reference().child("profilePhotos/\(uid).jpg")
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print(" Yükleme hatası: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print(" URL alma hatası: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let downloadURL = url else {
                    let unknownError = NSError(domain: "ProfilePhotoManager", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Download URL alınamadı."])
                    completion(.failure(unknownError))
                    return
                }

                // Firestore'a kaydet
                Firestore.firestore().collection("users").document(uid).updateData([
                    "profilePhotoURL": downloadURL.absoluteString
                ]) { firestoreError in
                    if let firestoreError = firestoreError {
                        print(" Firestore güncelleme hatası: \(firestoreError.localizedDescription)")
                        completion(.failure(firestoreError))
                        return
                    }

                    DispatchQueue.main.async {
                        self.imageURL = downloadURL
                    }

                    completion(.success(downloadURL))
                }
            }
        }
    }

    //Firestore'dan profil fotoğrafı URL'sini çeker ve state'e yazar
    func fetchProfileImageURL(completion: @escaping (URL?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }

        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print(" Firestore veri çekme hatası: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let data = snapshot?.data(),
               let urlString = data["profilePhotoURL"] as? String,
               let url = URL(string: urlString) {
                DispatchQueue.main.async {
                    self.imageURL = url
                    completion(url)
                }
            } else {
                completion(nil)
            }
        }
    }
}
