//
//  LoginSheetView.swift
//  Saporis
//
//  Created by Berat PORSUK on 3.07.2025.
//

import SwiftUI
import FirebaseAuth

struct LoginSheetView: View {
    @Binding var showLoginSheet: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showRegister = false
    @State private var showResetAlert = false
    @State private var resetAlertMessage = ""
    @State private var showLoginErrorAlert = false
    @State private var loginErrorMessage = ""

    @AppStorage("isUserLoggedIn") var isUserLoggedIn = false
    @AppStorage("rememberMe") var rememberMe = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Başlık ve açıklama
            VStack(spacing: 8) {
                Text("Saporis'e Giriş Yap")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Favorin olacak yeni mekanları kaydet, arkadaşlarına öner ve takip et, ve daha fazlası için giriş yap.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }

            // Giriş alanları
            VStack(spacing: 16) {
                TextField("E-posta", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                ZStack(alignment: .trailing) {
                    Group {
                        if showPassword {
                            TextField("Şifre", text: $password)
                        } else {
                            SecureField("Şifre", text: $password)
                        }
                    }
                    .textFieldStyle(.roundedBorder)

                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
                }

                // Beni Hatırla
                Toggle("Beni Hatırla", isOn: $rememberMe)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))

                // Şifremi Unuttum
                Button("Şifremi Unuttum") {
                    handlePasswordReset()
                }
                .font(.footnote)
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)

            // Giriş Butonu
            Button(action: handleLogin) {
                Text("Giriş Yap")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            // Kayıt Ol
            HStack {
                Text("Hesabın yok mu?")
                Button(action: {
                    showRegister = true
                }) {
                    Text("Kayıt Ol")
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
            .font(.footnote)

            // Vazgeç Butonu
            Button("Vazgeç") {
                showLoginSheet = false
            }
            .foregroundColor(.gray)
            .padding(.top, 12)

            Spacer()
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
        // Giriş Hatası Alert
        .alert("Giriş Başarısız", isPresented: $showLoginErrorAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(loginErrorMessage)
        }
        // Şifre Sıfırlama Alert
        .alert("Şifre Sıfırlama", isPresented: $showResetAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(resetAlertMessage)
        }
    }

    // MARK: - Giriş Fonksiyonu
    private func handleLogin() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                loginErrorMessage = error.localizedDescription
                showLoginErrorAlert = true
            } else {
                isUserLoggedIn = rememberMe ? true : false
                showLoginSheet = false
            }
        }
    }

    // MARK: - Şifremi Unuttum
    private func handlePasswordReset() {
        guard !email.isEmpty else {
            resetAlertMessage = "Lütfen önce e-posta adresinizi girin."
            showResetAlert = true
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                resetAlertMessage = error.localizedDescription
            } else {
                resetAlertMessage = "Şifre sıfırlama e-postası gönderildi."
            }
            showResetAlert = true
        }
    }
}

