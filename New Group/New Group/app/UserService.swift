//
//  UserService.swift
//  Saporis
//
//  Created by Berat PORSUK on 7.08.2025.
//

import Foundation
import FirebaseFirestore

class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()

    private init() {}

    func fetchUser(with uid: String, completion: @escaping (UserModel?) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                completion(nil)
                return
            }
            let user = UserModel(document: data, uid: uid)
            completion(user)
        }
    }
}

