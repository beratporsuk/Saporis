//
//  RegisterView.swift
//  Saporis
//
//  Created by Berat PORSUK on 3.07.2025.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss

    @State private var fullName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var city = ""

    @AppStorage("isUserLoggedIn") var isUserLoggedIn = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Başlık
            VStack(spacing: 8) {
                Text("Hesap Oluştur")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Saporis'e katıl, keşfetmeye başla!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Form alanları
            VStack(spacing: 16) {
                TextField("Ad Soyad", text: $fullName)
                    .textFieldStyle(.roundedBorder)

                TextField("Kullanıcı Adı", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)

                TextField("E-posta", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Şifre", text: $password)
                    .textFieldStyle(.roundedBorder)

                SecureField("Şifre Tekrar", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)

                TextField("Şehir (opsiyonel)", text: $city)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)

            // Kayıt Butonu
            Button(action: handleRegister) {
                Text("Kayıt Ol")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            // Giriş yap bağlantısı
            HStack {
                Text("Zaten hesabın var mı?")
                Button {
                    dismiss()
                } label: {
                    Text("Giriş Yap")
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
            .font(.footnote)

            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Hata"),
                message: Text(alertMessage),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }

    // 🔒 Firebase ile kayıt işlemi
    private func handleRegister() {
        guard !fullName.isEmpty, !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            alertMessage = "Lütfen tüm alanları doldurun."
            showAlert = true
            return
        }

        guard password == confirmPassword else {
            alertMessage = "Şifreler eşleşmiyor."
            showAlert = true
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }

            guard let user = result?.user else {
                alertMessage = "Kullanıcı oluşturulamadı."
                showAlert = true
                return
            }

            let db = Firestore.firestore()
            let userCity = city.isEmpty ? "Türkiye" : city

            db.collection("users").document(user.uid).setData([
                "uid": user.uid,
                "email": user.email ?? "",
                "username": username,
                "fullName": fullName,
                "city": userCity,
                "profilePhotoURL": "", // Şimdilik boş
                "createdAt": Timestamp()
            ]) { firestoreError in
                if let firestoreError = firestoreError {
                    print("Firestore Hatası: \(firestoreError.localizedDescription)")
                    alertMessage = "Kayıt başarılı fakat veriler kaydedilemedi."
                    showAlert = true
                } else {
                    print("Firestore: Kullanıcı verisi başarıyla kaydedildi.")
                    isUserLoggedIn = true
                    dismiss()
                }
            }
        }
    }
}
