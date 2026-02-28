//
//  LoginPromptView.swift
//  Saporis
//
//  Created by Berat PORSUK on 3.07.2025.
//

import SwiftUI

struct LoginPromptView: View {
    @Binding var showLoginSheet: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange.opacity(0.85))

            Text("Bu bölüme erişmek için giriş yapmalısınız.")
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                showLoginSheet = true
            }) {
                Text("Giriş Yap / Kayıt Ol")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }

            Spacer()
        }
    }
}
