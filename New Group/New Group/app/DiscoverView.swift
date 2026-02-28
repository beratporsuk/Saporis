//
//  DiscoverView.swift
//  app
//
//  Created by Berat PORSUK on 29.06.2025.
//
/*import SwiftUI
import FirebaseAuth
import MapKit



struct DiscoverView: View {
    @AppStorage("isUserLoggedIn") var isUserLoggedIn: Bool = false

    @StateObject private var placesService = PlacesService()
    
    @State private var searchText: String = ""
    
    @State private var showLoginSheet = false
    @State private var isNotificationViewOpen = false

    let categories = ["Pub", "Kahve", "Tatlı", "Akşam Yemeği", "Kahvaltı"]


    // ✅ Mock mekan verileri
    private let venues = MockData.venues

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Top Bar
            HStack {
                HStack(spacing: 8) {
                    Image("logoic")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Saporis")
                        .font(.title3)
                        .fontWeight(.bold)
                }

                Spacer()

                Button(action: {
                    if isUserLoggedIn {
                        isNotificationViewOpen = true
                    } else {
                        showLoginSheet = true
                    }
                }) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                        .imageScale(.medium)
                }
                .sheet(isPresented: $isNotificationViewOpen) {
                    NotificationView()
                }
                .fullScreenCover(isPresented: $showLoginSheet) {
                    AuthView(showLogin: $showLoginSheet)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .overlay(
                Text("Keşfet")
                    .font(.subheadline)
                    .fontWeight(.bold)
            )

            // MARK: - Search Bar
            TextField("Bir yer ara...", text: $searchText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(.search)

            // MARK: - Kategori Butonları
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            // MARK: - Mekan Kartları (DİNAMİK)
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(venues) { venue in
                        DiscoverCardView(venue: venue)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
        }
        .onAppear {
            isUserLoggedIn = Auth.auth().currentUser != nil
        }
    }
}*/
/*
import Foundation
import SwiftUI
import FirebaseAuth
import CoreLocation
import MapKit

struct DiscoverView: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var placesService = PlacesService()
    
    @State private var searchText: String = ""
    @State private var isUserLoggedIn = false
    @State private var showLoginSheet = false
    @State private var isNotificationViewOpen = false
    @State private var selectedCategory: String? = nil
    @State private var selectedPlace: GooglePlace? = nil
    @State private var isNavigatingToDetail = false
    @State private var userLocation: CLLocationCoordinate2D? = nil

    let quickCategories = ["Pub", "Kahve", "Tatlı", "Akşam Yemeği", "Kahvaltı"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                //  Üst Bar
                HStack {
                    HStack(spacing: 8) {
                        Image("logoic")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Saporis")
                            .font(.title3)
                            .fontWeight(.bold)
                    }

                    Spacer()

                    Button(action: {
                        if isUserLoggedIn {
                            isNotificationViewOpen = true
                        } else {
                            showLoginSheet = true
                        }
                    }) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .imageScale(.medium)
                    }
                    .sheet(isPresented: $isNotificationViewOpen) {
                        NotificationView()
                    }
                    .fullScreenCover(isPresented: $showLoginSheet) {
                        AuthView(showLogin: $showLoginSheet)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .overlay(
                    Text("Keşfet")
                        .font(.subheadline)
                        .fontWeight(.bold)
                )

                //  Arama Kutusu
                TextField("Bir yer ara...", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                    .onSubmit {
                        if let location = userLocation {
                            placesService.fetchNearbyPlaces(query: searchText, location: location)
                        }
                    }

                //  Kategori Butonları
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(quickCategories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                                searchText = category
                                if let location = userLocation {
                                    placesService.fetchNearbyPlaces(query: category, location: location)
                                }
                            }) {
                                Text(category)
                                    .font(.subheadline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedCategory == category ?
                                        Color.orange : Color.orange.opacity(0.2)
                                    )
                                    .foregroundColor(selectedCategory == category ? .white : .black)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                //  Konum Bilgisi Yüklenmiyorsa Uyarı
                if userLocation == nil {
                    Text("Konum bilgisi alınıyor...")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }

                //  Mekan Kartları
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(placesService.places) { place in
                            Button {
                                placesService.fetchPlaceDetails(placeID: place.place_id) { fetchedPlace in
                                    if let detailed = fetchedPlace {
                                        self.selectedPlace = detailed
                                        self.isNavigatingToDetail = true
                                    }
                                }
                            } label: {
                                DiscoverCardView(place: place, selectedPlace: $selectedPlace)
                                    .environmentObject(placesService)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
                .navigationDestination(isPresented: $isNavigatingToDetail) {
                    if let place = selectedPlace {
                        VenueDetailView(place: place)
                            .onDisappear {
                                isNavigatingToDetail = false
                                selectedPlace = nil
                            }
                    }
                }
            }
            .onAppear {
                isUserLoggedIn = Auth.auth().currentUser != nil
                userLocation = locationManager.userLocation
            }
            .onReceive(locationManager.$userLocation) { updated in
                userLocation = updated
            }
            .navigationDestination(item: $selectedPlace) { place in
                VenueDetailView(place: place)
            }
        }
    }
}*/

import Foundation
import SwiftUI
import FirebaseAuth
import CoreLocation
import MapKit

struct DiscoverView: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var placesService = PlacesService()

    @State private var searchText: String = ""
    @State private var isUserLoggedIn = false
    @State private var showLoginSheet = false
    @State private var isNotificationViewOpen = false
    @State private var selectedCategory: String? = nil
    @State private var selectedPlace: GooglePlace? = nil
    @State private var isNavigatingToDetail = false
    @State private var userLocation: CLLocationCoordinate2D? = nil

    // 👇 Basit debounce için
    @State private var debounceWorkItem: DispatchWorkItem?

    let quickCategories = ["Pub", "Kahve", "Tatlı", "Akşam Yemeği", "Kahvaltı"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Üst Bar
                HStack {
                    HStack(spacing: 8) {
                        Image("logoic")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Saporis")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Button {
                        if isUserLoggedIn { isNotificationViewOpen = true }
                        else { showLoginSheet = true }
                    } label: {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .imageScale(.medium)
                    }
                    .sheet(isPresented: $isNotificationViewOpen) { NotificationView() }
                    .fullScreenCover(isPresented: $showLoginSheet) { AuthView(showLogin: $showLoginSheet) }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .overlay(
                    Text("Keşfet")
                        .font(.subheadline)
                        .fontWeight(.bold)
                )

                // Arama Kutusu
                TextField("Bir yer ara...", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                    .onSubmit {
                        guard let loc = userLocation,
                              searchText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else { return }
                        placesService.fetchNearbyPlaces(query: searchText, location: loc)
                        placesService.endSearchSession()
                    }
                    .onChange(of: searchText) { old, newVal in
                        // oturum yönetimi
                        if old.isEmpty && !newVal.isEmpty { placesService.startSearchSession() }
                        if newVal.isEmpty {
                            placesService.endSearchSession()
                            if let loc = userLocation {
                                placesService.fetchNearbyPlaces(query: "restaurant", location: loc)
                            }
                        }

                        // 👇 Debounce
                        debounceWorkItem?.cancel()
                        let work = DispatchWorkItem { [searchText] in
                            guard let loc = userLocation,
                                  searchText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else { return }
                            placesService.fetchNearbyPlaces(query: searchText, location: loc)
                        }
                        debounceWorkItem = work
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.40, execute: work)
                    }

                // Kategori Butonları
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(quickCategories, id: \.self) { category in
                            Button {
                                selectedCategory = category
                                searchText = category
                                if let loc = userLocation {
                                    placesService.startSearchSession()
                                    // kategori tıklandığında debouncela bekleme
                                    placesService.fetchNearbyPlaces(query: category, location: loc)
                                }
                            } label: {
                                Text(category)
                                    .font(.subheadline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.orange : Color.orange.opacity(0.2))
                                    .foregroundColor(selectedCategory == category ? .white : .black)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                if userLocation == nil {
                    Text("Konum bilgisi alınıyor...")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }

                // Mekan Kartları
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(placesService.places) { place in
                            Button {
                                placesService.fetchPlaceDetails(placeID: place.place_id) { fetched in
                                    if let detailed = fetched {
                                        selectedPlace = detailed
                                        isNavigatingToDetail = true
                                    }
                                }
                                placesService.endSearchSession()
                            } label: {
                                DiscoverCardView(place: place, selectedPlace: $selectedPlace)
                                    .environmentObject(placesService)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
                .navigationDestination(isPresented: $isNavigatingToDetail) {
                    if let place = selectedPlace {
                        VenueDetailView(place: place)
                            .environmentObject(placesService) 
                            .onDisappear {
                                isNavigatingToDetail = false
                                selectedPlace = nil
                            }
                    }
                }
            }
            .onAppear {
                isUserLoggedIn = Auth.auth().currentUser != nil
                userLocation = locationManager.userLocation
                if let loc = userLocation {
                    // açılışta tek “yakındakiler”
                    placesService.fetchNearbyPlaces(query: "restaurant", location: loc)
                }
            }
            .onReceive(locationManager.$userLocation) { updated in
                userLocation = updated
            }
            .navigationDestination(item: $selectedPlace) { place in
                VenueDetailView(place: place)
            }
        }
    }
}
