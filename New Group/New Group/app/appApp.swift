//
//  appApp.swift
//  app
//
//  Created by Berat PORSUK on 29.06.2025.
//

import SwiftUI
import SwiftData
import Firebase
import FirebaseAuth

@main
struct appApp: App {
    @AppStorage("isUserLoggedIn") var isUserLoggedIn: Bool = false
    @StateObject var  locationManager = LocationManager()

    init() {
        FirebaseApp.configure()
        
        // Oturum kontrolü: kullanıcı varsa otomatik login durumu
        if Auth.auth().currentUser != nil {
            isUserLoggedIn = true
        } else {
            isUserLoggedIn = false
        }
    }

    // SwiftData model container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
         
          MainTabView()
            .modelContainer(sharedModelContainer)
            .environmentObject(locationManager)
        }
    }
}
