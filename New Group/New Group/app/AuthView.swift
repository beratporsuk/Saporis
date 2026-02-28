//
//  AuthView.swift
//  Saporis
//
//  Created by Berat PORSUK on 3.07.2025.
//

import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @Binding var showLogin: Bool
    @AppStorage("isUserLoggedIn") var isUserLoggedIn: Bool = false

    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true

    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    @State private var isPasswordVisible = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // MARK: - Kapama Butonu
                HStack {
                    Spacer()
                    Button {
                        showLogin = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                // MARK: - Başlık
                Text(isLoginMode ? "Giriş Yap" : "Kayıt Ol")
                    .font(.title)
                    .fontWeight(.semibold)

                // MARK: - Email Alanı
                TextField("E-posta", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                // MARK: - Şifre Alanı
                HStack {
                    Group {
                        if isPasswordVisible {
                            TextField("Şifre", text: $password)
                        } else {
                            SecureField("Şifre", text: $password)
                        }
                    }
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

                // MARK: - Gönder Butonu
                Button(action: handleAuth) {
                    Text(isLoginMode ? "Giriş Yap" : "Kayıt Ol")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // MARK: - Mod Değiştir
                Button(action: {
                    isLoginMode.toggle()
                }) {
                    Text(isLoginMode ? "Hesabınız yok mu? Kayıt olun" : "Zaten hesabınız var mı? Giriş yapın")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding()
            .alert("Hata", isPresented: $showErrorAlert) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Giriş / Kayıt Fonksiyonu
    private func handleAuth() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Lütfen tüm alanları doldurun."
            showErrorAlert = true
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Şifre en az 6 karakter olmalıdır."
            showErrorAlert = true
            return
        }

        if isLoginMode {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                } else {
                    isUserLoggedIn = true
                    showLogin = false
                }
            }
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                } else {
                    isUserLoggedIn = true
                    showLogin = false
                }
            }
        }
    }
}
