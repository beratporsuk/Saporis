//
//  CheckInView.swift
//  app
//
//  Created by Berat PORSUK on 30.06.2025.
//
/*
import SwiftUI
import PhotosUI
import CoreLocation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct CheckInView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var userLocation: CLLocationCoordinate2D? = nil
    
    @State private var searchText: String = ""
    @State private var selectedVenueName: String? = nil
    @State private var suggestedVenueName: String? = nil
    @StateObject private var placesService = PlacesService()
    @State private var selectedVenue: Venue? = nil

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImagesData: [Data] = []

    @State private var captionText: String = ""
    @State private var isUploading = false
    
    @State private var shouldIgnoreSearchChange = false

    

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        venueSelectionSection()
                        photoPickerSection()
                        selectedPhotosPreview()
                        captionInputSection()
                        shareButtonSection()
                    }
                    .padding()
                }
            }
            .navigationTitle("Gönderi Oluştur")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                userLocation = locationManager.userLocation
                fetchSuggestedVenue()
            }
            .onReceive(locationManager.$userLocation) { newLoc in
                userLocation = newLoc
                fetchSuggestedVenue()
            }
        }
    }

    @ViewBuilder
    func venueSelectionSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mekan Seç")
                .font(.headline)

            if let suggested = suggestedVenueName {
                Text(" Konumuna göre önerilen: \(suggested)")
                    .font(.footnote)
                    .foregroundColor(.orange)
            }

            TextField("       Mekan ara...", text: $searchText)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Spacer()
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                )
                .onChange(of: searchText) {
                    guard let location = userLocation else { return }

                    let queryToSend = searchText.isEmpty ? "mekan" : searchText
                    placesService.fetchNearbyPlaces(query: queryToSend, location: location)
                }


            if !placesService.places.isEmpty {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(placesService.places, id: \ .id) { place in
                            Button {
                                shouldIgnoreSearchChange = true
                                
                                self.selectedVenue = Venue(from: place)
                                self.selectedVenueName = place.name
                                self.searchText = place.name //  Arama kutusunu otomatik doldur
                                self.placesService.places = []
                                hideKeyboard()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        shouldIgnoreSearchChange = false
                                    }


                            } label: {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title3)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(place.name)
                                            .font(.subheadline)
                                        Text(place.address)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
    }

    @ViewBuilder
    func photoPickerSection() -> some View {
        PhotosPicker(selection: $selectedItems, maxSelectionCount: 5, matching: .images) {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundColor(.orange)
                Text("Fotoğraf Ekle (Max 5)")
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .onChange(of: selectedItems) {
            selectedImagesData = []
            for item in selectedItems {
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        selectedImagesData.append(data)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func selectedPhotosPreview() -> some View {
        if !selectedImagesData.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(selectedImagesData, id: \ .self) { data in
                        if let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    func captionInputSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Açıklama")
                .font(.headline)
            TextEditor(text: $captionText)
                .frame(height: 150)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(16)
        }
    }

    @ViewBuilder
    func shareButtonSection() -> some View {
        Button {
            uploadPost()
        } label: {
            HStack {
                Spacer()
                if isUploading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Paylaş")
                        .bold()
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding()
            .background(Color.orange)
            .cornerRadius(16)
            .shadow(radius: 5)
        }
        .disabled(isUploading)
    }

    func fetchSuggestedVenue() {
        guard let location = userLocation else { return }
        placesService.fetchNearbyPlaces(query: searchText, location: location)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let first = placesService.places.first {
                suggestedVenueName = first.name
            }
        }
    }

    func uploadImagesToStorage(completion: @escaping ([String]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        var uploadedURLs: [String] = []
        let storage = Storage.storage()
        let dispatchGroup = DispatchGroup()

        for imageData in selectedImagesData {
            dispatchGroup.enter()
            let imageID = UUID().uuidString
            let storageRef = storage.reference().child("post_images/\(userId)/\(imageID).jpg")

            storageRef.putData(imageData, metadata: nil) { _, error in
                if error == nil {
                    storageRef.downloadURL { url, _ in
                        if let url = url {
                            uploadedURLs.append(url.absoluteString)
                        }
                        dispatchGroup.leave()
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(uploadedURLs)
        }
    }

    func savePostToFirestore(imageURLs: [String]) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let postData: [String: Any] = [
            "userId": userId,
            "venueName": selectedVenueName ?? "",
            "commentText": captionText,
            "imageURLs": imageURLs,
            "timestamp": FieldValue.serverTimestamp()
        ]
        Firestore.firestore().collection("posts").addDocument(data: postData) { error in
            if error == nil {
                selectedImagesData = []
                captionText = ""
                selectedVenueName = nil
                searchText = ""
            }
            isUploading = false
        }
    }

    func uploadPost() {
        guard !selectedImagesData.isEmpty else { return }
        isUploading = true
        uploadImagesToStorage { imageURLs in
            if !imageURLs.isEmpty {
                savePostToFirestore(imageURLs: imageURLs)
            } else {
                isUploading = false
            }
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

*/

import SwiftUI
import PhotosUI
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct CheckInView: View {
    @EnvironmentObject var locationManager: LocationManager

    @State private var userLocation: CLLocationCoordinate2D? = nil

    @State private var searchText: String = ""
    @State private var selectedVenueName: String? = nil
    @State private var suggestedVenueName: String? = nil
    @StateObject private var placesService = PlacesService()
    @State private var selectedVenue: Venue? = nil

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImagesData: [Data] = []

    @State private var captionText: String = ""
    @State private var isUploading = false
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        venueSelectionSection()
                        photoPickerSection()
                        selectedPhotosPreview()
                        captionInputSection()
                        shareButtonSection()
                    }
                    .padding()
                }

                if let errorText {
                    VStack {
                        Spacer()
                        Text(errorText)
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.red.opacity(0.85))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 12)
                    .transition(.opacity)
                }
            }
            .navigationTitle("Gönderi Oluştur")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                userLocation = locationManager.userLocation
                fetchSuggestedVenue()
            }
            .onReceive(locationManager.$userLocation) { newLoc in
                userLocation = newLoc
                fetchSuggestedVenue()
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    func venueSelectionSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mekan Seç")
                .font(.headline)

            if let suggested = suggestedVenueName {
                Text("Konumuna göre önerilen: \(suggested)")
                    .font(.footnote)
                    .foregroundColor(.orange)
            }

            TextField("       Mekan ara...", text: $searchText)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        Spacer()
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                )
                .onChange(of: searchText) {
                    guard let location = userLocation else { return }
                    let queryToSend = searchText.isEmpty ? "mekan" : searchText
                    placesService.fetchNearbyPlaces(query: queryToSend, location: location)
                }

            if !placesService.places.isEmpty {
                ScrollView {
                    VStack(spacing: 8) {
                        // DİKKAT: id: \.id (araya boşluk koyma)
                        ForEach(placesService.places, id: \.id) { place in
                            Button {
                                self.selectedVenue = Venue(from: place)
                                self.selectedVenueName = place.name
                                self.searchText = place.name
                                self.placesService.places = []
                                hideKeyboard()
                            } label: {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title3)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(place.name).font(.subheadline)
                                        Text(place.address).font(.caption).foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
    }

    @ViewBuilder
    func photoPickerSection() -> some View {
        PhotosPicker(selection: $selectedItems, maxSelectionCount: 5, matching: .images) {
            HStack {
                Image(systemName: "photo.on.rectangle.angled").foregroundColor(.orange)
                Text("Fotoğraf Ekle (Max 5)")
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .onChange(of: selectedItems) {
            selectedImagesData = []
            for item in selectedItems {
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        await MainActor.run { selectedImagesData.append(data) }
                    }
                }
            }
        }
    }

    @ViewBuilder
    func selectedPhotosPreview() -> some View {
        if !selectedImagesData.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(selectedImagesData, id: \.self) { data in
                        if let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    func captionInputSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Açıklama").font(.headline)
            TextEditor(text: $captionText)
                .frame(height: 150)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(16)
        }
    }

    @ViewBuilder
    func shareButtonSection() -> some View {
        Button {
            Task { await uploadPost() }
        } label: {
            HStack {
                Spacer()
                if isUploading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Paylaş").bold().foregroundColor(.white)
                }
                Spacer()
            }
            .padding()
            .background(Color.orange)
            .cornerRadius(16)
            .shadow(radius: 5)
        }
        .disabled(isUploading)
    }

    // MARK: - Logic

    func fetchSuggestedVenue() {
        guard let location = userLocation else { return }
        let queryToSend = searchText.isEmpty ? "mekan" : searchText
        placesService.fetchNearbyPlaces(query: queryToSend, location: location)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let first = placesService.places.first {
                suggestedVenueName = first.name
            }
        }
    }

    @MainActor
    func uploadPost() async {
        // Basit doğrulamalar
        guard !isUploading else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            errorText = "Oturum açılmadı."; return
        }
        guard !selectedImagesData.isEmpty else {
            errorText = "En az bir fotoğraf ekle."; return
        }
        guard let venueName = (selectedVenue?.name) ?? selectedVenueName, !venueName.isEmpty else {
            errorText = "Bir mekan seç."; return
        }

        isUploading = true
        errorText = nil

        do {
            // 1) Görselleri Storage’a yükle (KURALLARA UYUMLU YOL: posts/{userId}/...)
            // FirebaseStorageManager.shared içindeki contentType/boyut/resize avantajlarından yararlanıyoruz
            let urls = try await FirebaseStorageManager.shared.uploadPostImages(userId: uid, imagesData: selectedImagesData)

            // 2) Firestore'a yaz
            let postData: [String: Any] = [
                "userId": uid,
                "venueName": venueName,
                "commentText": captionText,
                "imageURLs": urls,
                "timestamp": FieldValue.serverTimestamp()
            ]
            try await Firestore.firestore().collection("posts").addDocument(data: postData)

            // 3) UI reset
            selectedImagesData = []
            captionText = ""
            selectedVenueName = nil
            searchText = ""

        } catch {
            errorText = error.localizedDescription
        }
        isUploading = false
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

