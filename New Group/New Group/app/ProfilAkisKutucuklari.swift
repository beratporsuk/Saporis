//
//  ProfilAkisKutucuklari.swift
//  app
//
//  Created by Berat PORSUK on 30.06.2025.
//
import SwiftUI

struct ProfilAkisKutucuklari: View {
    var body: some View {
        VStack(spacing: 12) {
            NavigationLink(destination: FavoriMekanlarView()) {
                AkisKutucukView(title: "Favori Mekanlarım", icon: "star.fill")
            }
            NavigationLink(destination: KaydedilenYerlerView()) {
                AkisKutucukView(title: "Kaydedilen Yerler", icon: "bookmark.fill")
            }
            NavigationLink(destination: KesfedilenYerlerView()) {
                AkisKutucukView(title: "Keşfedilen Yerler", icon: "magnifyingglass.circle.fill")
            }
            NavigationLink(destination: RozetlerView()) {
                AkisKutucukView(title: "Rozetlerim", icon: "rosette")
            }
            NavigationLink(destination: EtiketliListelerView()) {
                AkisKutucukView(title: "Etiketli Listelerim", icon: "tag.fill")
            }
        }
        .padding(.horizontal)
    }
}

struct AkisKutucukView: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
#Preview {
    ProfilAkisKutucuklari()
}
