//
//  SettingsView.swift
//  app
//
//  Created by Berat PORSUK on 3.07.2025.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @AppStorage("isUserLoggedIn") var isUserLoggedIn: Bool = false
    // Profil güncellendiyse üst view'a haber ver
    @Binding var showLogin: Bool
    var onProfileUpdated: () -> Void 
    
    @State private var isNotificationOn = true
    @State private var isPrivateProfile = false
    @State private var showLogoutAlert = false

    
    

    var body: some View {
        
            Form {
                // MARK: - HESAP
                Section(header: Text("Hesap")) {
                    NavigationLink {
                        ProfileEditView(
                            onSave: {
                                // Profil bilgileri değiştiğinde yukarıya bildir
                                onProfileUpdated()
                                NotificationCenter.default.post(name: .profilePhotoUpdated, object: nil)

                            }
                        )
                    } label: {
                        Label("Profil Bilgilerim", systemImage: "person.circle")
                    }

                    NavigationLink {
                        // Buraya şifre değiştirme view'i entegre edilecek
                        Text("Şifre Değiştir")
                    } label: {
                        Label("Şifre Değiştir", systemImage: "lock.rotation")
                    }
                }

                // MARK: - GİZLİLİK
                Section(header: Text("Gizlilik")) {
                    Toggle(isOn: $isPrivateProfile) {
                        Label("Gizli Profil", systemImage: "eye.slash")
                    }
                }

                // MARK: - BİLDİRİMLER
                Section(header: Text("Bildirimler")) {
                    Toggle(isOn: $isNotificationOn) {
                        Label("Bildirimleri Aç", systemImage: "bell.badge")
                    }
                }

                // MARK: - ÇIKIŞ
                Section {
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        Label("Çıkış Yap", systemImage: "arrow.backward.circle.fill")
                    }
                }
            }
            .navigationTitle("Ayarlar")
            .alert("Oturumunuzu kapatmak istediğinize emin misiniz?", isPresented: $showLogoutAlert) {
                Button("Çıkış Yap", role: .destructive) {
                    handleLogout()
                }
                Button("Vazgeç", role: .cancel) {}
            }
        }
    // MARK: - Logout Handler
private func handleLogout() {
        do {
            try Auth.auth().signOut()
            isUserLoggedIn = false
            showLogin = false

            // Diğer view'lara haber ver
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .logoutCompleted, object: nil)
            }
        } catch {
            print("Çıkış başarısız: \(error.localizedDescription)")
        }
    }
}



