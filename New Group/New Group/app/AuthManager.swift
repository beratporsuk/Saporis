//
//  AuthManager.swift
//  Saporis
//
//  Created by Berat PORSUK on 6.07.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthManager {
    static let shared = AuthManager()
    private init() {}
    
    let db = Firestore.firestore()

    func registerUser(email: String, password: String, username: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }

            guard let user = result?.user else {
                completion(false, "Kullanıcı oluşturulamadı.")
                return
            }

            // Firestore’a veri yaz
            let userData: [String: Any] = [
                "uid": user.uid,
                "email": email,
                "username": username,
                "createdAt": Timestamp()
            ]

            self.db.collection("users").document(user.uid).setData(userData) { err in
                if let err = err {
                    completion(false, "Firestore yazma hatası: \(err.localizedDescription)")
                } else {
                    completion(true, nil)
                }
            }
        }
    }
}

