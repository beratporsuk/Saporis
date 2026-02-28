//
//  HomeView.swift
//  app
//
//  Created by Berat PORSUK on 29.06.2025.
//

import SwiftUI

struct HomeView: View {
    @State private var showLogin = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("WELCOME TO SAPORIS")
                    .font(.largeTitle)
                    .foregroundColor(.pri1)
                
                NavigationLink(destination: SearchView()) {
                    Text("Search")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                NavigationLink(destination: ProfileView(showLogin: $showLogin)) {
                    Text("Your Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.bg1)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
