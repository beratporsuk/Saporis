//
//  UserModel.swift
//  Saporis
//
//  Created by Berat PORSUK on 6.07.2025.
//

import Foundation

struct UserModel: Identifiable {
    var id: String { uid }
    
    let uid: String
    let email: String?
    let username: String?
    let fullName: String?
    let city: String?
    let profilePhotoURL: String?
    
    init(
        uid: String,
        email: String? = nil,
        username: String? = nil,
        fullName: String? = nil,
        city: String? = nil,
        profilePhotoURL: String? = nil
        
        
    ) {
        self.uid = uid
        self.email = email
        self.username = username
        self.fullName = fullName
        self.city = city
        self.profilePhotoURL = profilePhotoURL
    }

    // Firestore'dan gelen veriyle model oluşturmak için
    init?(document: [String: Any], uid: String) {
        self.uid = uid
        self.email = document["email"] as? String
        self.username = document["username"] as? String
        self.fullName = document["fullName"] as? String
        self.city = document["city"] as? String
        self.profilePhotoURL = document["profilePhotoURL"] as? String
    }
}

