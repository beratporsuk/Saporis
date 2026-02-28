//
//  DiscoverCardView.swift
//  app
//
//  Created by Berat PORSUK on 29.06.2025.
//

/*

import SwiftUI


struct DiscoverCardView: View {
    let place: GooglePlace
    @Binding var selectedPlace: GooglePlace?
    @EnvironmentObject var placesService: PlacesService

    var body: some View {
        NavigationLink(value: place) {
            HStack(alignment: .top, spacing: 14) {
                //  Fotoğraf
                if let urlString = place.getPhotoURLs().first, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipped()
                            .cornerRadius(10)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                            .frame(width: 120, height: 120)
                            .cornerRadius(10)
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.orange)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                }

                //  Bilgi bloğu
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(place.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(2)

                        Spacer()

                        if let rating = place.rating {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Text(String(format: "%.1f", rating))
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                        }

                        if let total = place.user_ratings_total {
                            Text("(\(total))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    if let components = place.formatted_address?.components(separatedBy: ","),
                       components.count >= 2 {
                        let simplified = components.suffix(2).joined(separator: " / ").replacingOccurrences(of: " Türkiye", with: "")
                        Text(simplified)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    if let isOpen = place.opening_hours?.open_now {
                        Text(isOpen ? "Şu anda açık" : "Kapalı")
                            .font(.caption)
                            .foregroundColor(isOpen ? .green : .red)
                    }

                    HStack(spacing: 8) {
                        if let price = place.price_level {
                            Text(String(repeating: "$", count: price))
                                .font(.caption)
                        }
                    }

                    Text(place.wasRecommendedByAFriend ?
                         " Bir arkadaşın önerdi" :
                         "Daha önce hiçbir arkadaşın burayı keşfetmedi.")
                    .font(.caption2)
                    .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
        .simultaneousGesture(TapGesture().onEnded {
            // Detay verilerini çek
            placesService.fetchPlaceDetails(placeID: place.place_id) { detailedPlace in
                if let detailedPlace = detailedPlace {
                    self.selectedPlace = detailedPlace
                }
            }
        })
    }
}
*/

import SwiftUI

struct DiscoverCardView: View {
    let place: GooglePlace
    @Binding var selectedPlace: GooglePlace?
    @EnvironmentObject var placesService: PlacesService

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            //  Fotoğraf
            if let urlString = place.getPhotoURLs().first, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipped()
                        .cornerRadius(10)
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .frame(width: 120, height: 120)
                        .cornerRadius(10)
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .foregroundColor(.orange)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
            }

            //  Bilgi bloğu
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(place.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if let rating = place.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(String(format: "%.1f", rating))
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                    }
                    // components.count >= 2 {
                    //let simplified = components.suffix(2).joined(separator: " / ").replacingOccurrences(of: " Türkiye", with: "")
                    if let total = place.user_ratings_total {
                        Text("(\(total))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                if let address = place.cleanedAddress {
                    
                    
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                

                if let isOpen = place.opening_hours?.open_now {
                    Text(isOpen ? "Şu anda açık" : "Kapalı")
                        .font(.caption)
                        .foregroundColor(isOpen ? .green : .red)
                }

                HStack(spacing: 8) {
                    if let priceText = place.formattedPriceLevel {
                        Text(priceText)
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(6)
                    }

                }

                Text(place.wasRecommendedByAFriend ?
                     " Bir arkadaşın önerdi" :
                     "Daha önce hiçbir arkadaşın burayı keşfetmedi.")
                .font(.caption2)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .onTapGesture {
            
           
            
           
            placesService.fetchPlaceDetails(placeID: place.place_id) { detailedPlace in
                if let detailedPlace = detailedPlace {
                    self.selectedPlace = detailedPlace
                } else {
                    self.selectedPlace = place // fallback olarak eski halini gönder
                }
            }
        }
    }
}

