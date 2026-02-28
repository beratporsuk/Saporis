//
//  RecommendedVenueCardView.swift
//  Saporis
//
//  Created by Berat PORSUK on 15.07.2025.
//

import SwiftUI
typealias VenueModel = Venue
struct RecommendedVenueCardView: View {
   

    let venue: VenueModel
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(venue.name)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("\(venue.category) • \(venue.city)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Image(systemName: "star.circle.fill")
                        .foregroundColor(.orange)
                        .font(.title3)
                }

                Divider()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle()) // Buton görünümünü bozmaz
    }
}
