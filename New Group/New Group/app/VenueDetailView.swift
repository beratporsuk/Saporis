//
//  VenueDetailView.swift
//  Saporis
//
//  Created by Berat PORSUK on 15.07.2025.
//


/*
 // Fotoğraf Galerisi
 if !place.getPhotoURLs().isEmpty {
     ScrollView(.horizontal, showsIndicators: false) {
         HStack(spacing: 12) {
             ForEach(place.getPhotoURLs().prefix(10), id: \.self) { urlString in
                 if let url = URL(string: urlString) {
                     AsyncImage(url: url) { image in
                         image
                             .resizable()
                             .scaledToFill()
                             .frame(width: 280, height: 180)
                             .clipped()
                             .cornerRadius(12)
                     } placeholder: {
                         RoundedRectangle(cornerRadius: 12)
                             .fill(Color.gray.opacity(0.2))
                             .frame(width: 280, height: 180)
                     }
                 }
             }
         }
         .padding(.horizontal)
     }
 }*/

/*
import SwiftUI
import MapKit

struct VenueDetailView: View {
    
    let place: GooglePlace
    @State private var isFavorited = false
    @State private var showShareSheet = false
    @State private var showCommentSheet = false
    @State private var selectedImageURL: URL? = nil
    @State private var isShowingFullScreen = false
    @State private var showCommentsView = false



    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
               
                let photoURLs = place.getPhotoURLs().prefix(10)

                if !photoURLs.isEmpty {
                    TabView {
                        ForEach(photoURLs, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 250)
                                        .clipped()
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 6)
                                        //.onTapGesture {
                                          //  selectedImageURL = url
                                            //isShowingFullScreen = true
                                        //}
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 280, height: 180)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: UIScreen.main.bounds.height * 0.28)
                    .padding(.horizontal)
                }
                
                //  İsim & Adres
                VStack(alignment: .leading, spacing: 6) {
                    Text(place.name)
                        .font(.title)
                        .fontWeight(.bold)

                    if let address = place.formatted_address {
                        Text(address)
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)

                //  Puan + Yorum Sayısı
                HStack(spacing: 10) {
                    if let rating = place.rating {
                        Label(String(format: "%.1f", rating), systemImage: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.subheadline)
                    }

                    if let totalCount = place.user_ratings_total, totalCount > 0 {
                        Button(action: {
                            showCommentsView = true
                        }) {
                            Text("\(totalCount) Yorum")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 8)
                        .sheet(isPresented: $showCommentsView) {
                            CommentsDetailsView(venue: Venue(from: place)) //  GooglePlace → Venue
                        }
                    }


                }
                .padding(.horizontal)
                
                //  Arkadaş Önerisi
                if place.wasRecommendedByAFriend {
                    Text(" Bir arkadaşın burayı önerdi!")
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                } else {
                    Text("Daha önce hiçbir arkadaşın burayı keşfetmedi.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                //  Aksiyon Butonları
                HStack(spacing: 5) {
                    Button(action: {
                        isFavorited = true
                    }) {
                        HStack {
                            Image(systemName: isFavorited ? "heart.fill" : "heart")
                            Text(isFavorited ? "Favoride" : "Favori Ekle")
                        }
                        .padding()
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(10)
                    }

                    Button(action: {
                        showCommentSheet = true
                    }) {
                        HStack {
                            Image(systemName: "text.bubble")
                            Text("Değerlendirme Yap")
                        }
                        .padding()
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(10)
                    }
                    .sheet(isPresented: $showCommentSheet) {
                        CommentView(venue: Venue(from: place))
                    }

                    Button(action: {
                        showShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Öner")
                        }
                        .padding()
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(10)
                    }
                    .sheet(isPresented: $showShareSheet) {
                        ShareSheet(activityItems: ["Saporis'te bu mekanı öneriyorum: \(place.name)"])
                    }
                }
                .font(.footnote)
                .padding(.horizontal)
                .padding(.bottom, 30)

                //  Açılış Bilgisi
                if let isOpen = place.opening_hours?.open_now {
                    Text(isOpen ? "Şu anda açık" : "Şu anda kapalı")
                        .font(.subheadline)
                        .foregroundColor(isOpen ? .green : .red)
                        .padding(.horizontal)
                }

                if let hours = place.opening_hours?.weekday_text {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Haftalık Açılış Saatleri:")
                            .font(.subheadline)
                            .bold()
                        ForEach(hours, id: \.self) { line in
                            Text(line)
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal)
                }

                //  Fiyat Seviyesi
                if let priceText = place.formattedPriceLevel {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ortalama Fiyat Aralığı: \(priceText)")
                            .font(.subheadline)
                            .bold()

                        Text("Bu fiyat aralığı, Google tarafından sunulan price_level değerine dayalı tahmini bir seviyedir:")
                            .font(.caption)
                            .foregroundColor(.gray)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("0 → ₺0–150")
                            Text("1 → ₺150-300")
                            Text("2 → ₺300–500")
                            Text("3 → ₺500-1000")
                            Text("4 → ₺1000+")
                        }
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.8))
                    }
                    .padding(.horizontal)
                }
                
                
                Section(header: Text("Daha fazla Bilgi: ")
                    .font(.subheadline)
                    .bold()
                   ){
                    if let website = place.website {
                        Link(destination: URL(string: website)!) {
                            Label(website.contains("menu") ? " Menüye Göz At" : " Web Sitesine Git", systemImage: "safari")
                        }
                    }
                }
                   .padding(.horizontal)




                //  Haritada Göster
                Button(action: {
                    openInMaps(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng, placeName: place.name)
                }) {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Haritada Göster")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

               

                
            }
            .padding(.top)
        }
        .navigationTitle(place.name)
        .navigationBarTitleDisplayMode(.inline)
        

        
       /* .fullScreenCover(isPresented: $isShowingFullScreen) {
            if let imageURL = selectedImageURL {
                ZStack(alignment: .topTrailing) {
                    Color.black.ignoresSafeArea()
                    
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .ignoresSafeArea()
                    } placeholder: {
                        ProgressView()
                    }
                    
                    Button(action: {
                        isShowingFullScreen = false
                        selectedImageURL = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }
            else {
                // fallback görünüm
                Color.black
                    .overlay(Text("Görsel yüklenemedi").foregroundColor(.white))
            }
        }*/
        
    }

    // MARK: - Maps Aç
    private func openInMaps(latitude: Double, longitude: Double, placeName: String) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = placeName
        mapItem.openInMaps()
        
        
    }
}
*/

import SwiftUI
import MapKit

struct VenueDetailView: View {

    let place: GooglePlace
    @State private var isFavorited = false
    @State private var showShareSheet = false
    @State private var showCommentSheet = false
    @State private var selectedImageURL: URL? = nil
    @State private var isShowingFullScreen = false
    @State private var showCommentsView = false

    // 👇 PlacesService’e eriş (Discover’dan .environmentObject ile vereceğiz)
    @EnvironmentObject var placesService: PlacesService

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Foto galerisi (prefix 10)
                let photoURLs = place.getPhotoURLs().prefix(10)
                if !photoURLs.isEmpty {
                    TabView {
                        ForEach(photoURLs, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 250)
                                        .clipped()
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 6)
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 280, height: 180)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: UIScreen.main.bounds.height * 0.28)
                    .padding(.horizontal)
                }

                // İsim & Adres
                VStack(alignment: .leading, spacing: 6) {
                    Text(place.name).font(.title).fontWeight(.bold)
                    if let address = place.formatted_address {
                        Text(address).foregroundColor(.gray).font(.subheadline)
                    }
                }
                .padding(.horizontal)

                // Puan + Yorum Sayısı (yorumlar on-demand)
                HStack(spacing: 10) {
                    if let rating = place.rating {
                        Label(String(format: "%.1f", rating), systemImage: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.subheadline)
                    }

                    if let totalCount = place.user_ratings_total, totalCount > 0 {
                        Button {
                            // Yorumları on-demand çek, sonra CommentsDetailsView’i aç
                            placesService.fetchPlaceReviews(placeID: place.place_id) { _ in
                                showCommentsView = true
                            }
                        } label: {
                            Text("\(totalCount) Yorum")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 8)
                        .sheet(isPresented: $showCommentsView) {
                            CommentsDetailsView(venue: Venue(from: placesService.selectedPlace ?? place))
                                .environmentObject(placesService)
                        }
                    }
                }
                .padding(.horizontal)

                // Arkadaş önerisi
                Group {
                    if place.wasRecommendedByAFriend {
                        Text("Bir arkadaşın burayı önerdi!")
                            .font(.footnote).foregroundColor(.blue)
                    } else {
                        Text("Daha önce hiçbir arkadaşın burayı keşfetmedi.")
                            .font(.footnote).foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                // Aksiyonlar
                HStack(spacing: 5) {
                    Button {
                        isFavorited = true
                    } label: {
                        HStack { Image(systemName: isFavorited ? "heart.fill" : "heart"); Text(isFavorited ? "Favoride" : "Favori Ekle") }
                            .padding().background(Color.orange.opacity(0.15)).cornerRadius(10)
                    }

                    Button { showCommentSheet = true } label: {
                        HStack { Image(systemName: "text.bubble"); Text("Değerlendirme Yap") }
                            .padding().background(Color.orange.opacity(0.15)).cornerRadius(10)
                    }
                    .sheet(isPresented: $showCommentSheet) {
                        CommentView(venue: Venue(from: place))
                    }

                    Button { showShareSheet = true } label: {
                        HStack { Image(systemName: "paperplane.fill"); Text("Öner") }
                            .padding().background(Color.orange.opacity(0.15)).cornerRadius(10)
                    }
                    .sheet(isPresented: $showShareSheet) {
                        ShareSheet(activityItems: ["Saporis'te bu mekanı öneriyorum: \(place.name)"])
                    }
                }
                .font(.footnote)
                .padding(.horizontal)
                .padding(.bottom, 30)

                // Açık mı?
                if let isOpen = place.opening_hours?.open_now {
                    Text(isOpen ? "Şu anda açık" : "Şu anda kapalı")
                        .font(.subheadline)
                        .foregroundColor(isOpen ? .green : .red)
                        .padding(.horizontal)
                }

                // Haftalık saatler
                if let hours = place.opening_hours?.weekday_text {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Haftalık Açılış Saatleri:").font(.subheadline).bold()
                        ForEach(hours, id: \.self) { Text($0).font(.caption) }
                    }
                    .padding(.horizontal)
                }

                // Fiyat seviyesi
                if let priceText = place.formattedPriceLevel {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ortalama Fiyat Aralığı: \(priceText)").font(.subheadline).bold()
                        Text("Bu fiyat aralığı, Google tarafından sunulan price_level değerine dayalı tahmini bir seviyedir:")
                            .font(.caption).foregroundColor(.gray)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("0 → ₺0–150")
                            Text("1 → ₺150-300")
                            Text("2 → ₺300–500")
                            Text("3 → ₺500-1000")
                            Text("4 → ₺1000+")
                        }
                        .font(.caption2).foregroundColor(.gray.opacity(0.8))
                    }
                    .padding(.horizontal)
                }

                // Daha Fazla Bilgi
                Section(header:
                    Text("Daha Fazla Bilgi:").font(.subheadline).bold()
                ) {
                    if let website = place.website, let url = URL(string: website) {
                        Link(destination: url) {
                            Label(website.contains("menu") ? "Menüye Göz At" : "Web Sitesine Git", systemImage: "safari")
                        }
                    }
                }
                .padding(.horizontal)

                // Haritada Göster
                Button {
                    openInMaps(latitude: place.geometry.location.lat,
                               longitude: place.geometry.location.lng,
                               placeName: place.name)
                } label: {
                    HStack { Image(systemName: "map.fill"); Text("Haritada Göster") }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                // 👇 Google attribution (uyumluluk için)
                HStack {
                    Spacer()
                    Text("Data © Google")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.top, 4)
            }
            .padding(.top)
        }
        .navigationTitle(place.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Maps Aç
    private func openInMaps(latitude: Double, longitude: Double, placeName: String) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = placeName
        mapItem.openInMaps()
    }
}

