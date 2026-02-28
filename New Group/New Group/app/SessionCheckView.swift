//
//  SessionCheckView.swift
//  Saporis
//
//  Created by Berat PORSUK on 3.07.2025.
//

import SwiftUI
import FirebaseAuth

struct SessionCheckView: View {
    @Binding var isLoggedIn: Bool
    @Binding var isSessionChecked: Bool

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                Text("Oturum kontrol ediliyor...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if let _ = Auth.auth().currentUser {
                    isLoggedIn = true
                } else {
                    isLoggedIn = false
                }
                isSessionChecked = true
            }
        }
    }
}

