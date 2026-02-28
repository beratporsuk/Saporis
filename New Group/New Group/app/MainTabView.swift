//
//  MainTabView.swift
//  app
//
//  Created by Berat PORSUK on 30.06.2025.
//

import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showLoginSheet = false
    @State private var showAuthView = false
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false

    var body: some View {
        TabView(selection: $selectedTab) {

            DiscoverView()
                .tabItem {
                    Label("Keşfet", systemImage: "safari")
                }
                .tag(0)

            ProtectedTab(content: FeedView(), showLogin: $showLoginSheet)
                .tabItem {
                    Label("Akış", systemImage: "square.stack.3d.up.fill")
                }
                .tag(1)

            ProtectedTab(content: CheckInView(), showLogin: $showLoginSheet)
                .tabItem {
                    Label("Check-in", systemImage: "location.fill")
                }
                .tag(2)

            ProtectedTab(content: ProfileView(showLogin: $showLoginSheet), showLogin: $showLoginSheet)
                .tabItem {
                    Label("Profil", systemImage: "person.crop.circle")
                }
                .tag(3)
        }
        // Giriş sayfası modal (sheet) olarak açılır
        .sheet(isPresented: $showLoginSheet) {
            LoginSheetView(showLoginSheet: $showLoginSheet)
        }

        // Giriş yapma işlemi başlatılırsa tam ekran olarak AuthView açılır
        .fullScreenCover(isPresented: $showAuthView) {
            AuthView(showLogin: $showAuthView)
        }

        // Bildirimle gelen tetikleyici, AuthView'i açar
        .onReceive(NotificationCenter.default.publisher(for: .triggerLogin)) { _ in
            showAuthView = true
        }

        // Çıkış sonrası Keşfet ekranına dön
        .onReceive(NotificationCenter.default.publisher(for: .logoutCompleted)) { _ in
            selectedTab = 0
        }
    }
}



#Preview {
    MainTabView()
}
