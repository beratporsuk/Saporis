//
//  RecommendedVenuesDetailView.swift
//  Saporis
//
//  Created by Berat PORSUK on 15.07.2025.
//

import Foundation
import SwiftUI

struct RecommendedVenuesDetailView: View {
    let venues: [Venue]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("\u{1F4E4} Önerdiğim Mekanlar")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)

                ForEach(venues) { venue in
                    RecommendedVenueCardView(venue: venue)
                }
            }
            .padding(.top)
        }
        .navigationTitle("Önerdiklerim")
        .navigationBarTitleDisplayMode(.inline)
    }
}


