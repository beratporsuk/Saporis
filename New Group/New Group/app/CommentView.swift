//
//  CommentView.swift
//  Saporis
//
//  Created by Berat PORSUK on 19.07.2025.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct CommentView: View {
    let venue: Venue
    @Environment(\.dismiss) var dismiss

    @State private var commentText: String = ""
    @State private var rating: Int = 0 // Puan
    @State private var isSending = false
    @State private var alertMessage = ""
    @State private var showAlert = false

    //  Fotoğraf Seçimi
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {

                //  Mekan Adı
                Text("\(venue.name) İçin Değerlendirmen:")
                    .font(.headline)

                //  Puan Verme Alanı
                Text("Puan Ver:")
                    .font(.subheadline)
                    .bold()
                    
                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.orange)
                            .onTapGesture {
                                rating = index
                            }
                    }
                }
                .frame(maxWidth: .infinity) // Tam genişlik kaplasın
                .padding(.vertical, 4)
                .multilineTextAlignment(.center) // Metin ortalansın
                

                //  Yorum Girişi
                Text("Yorum :")
                    .font(.subheadline)
                    .bold()

                TextEditor(text: $commentText)
                    .frame(height: 150)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))

                // Seçilen Fotoğraf Önizleme
                if let data = selectedImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .cornerRadius(12)
                        .clipped()
                }

                //  Fotoğraf Seçme Butonu
                PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Fotoğraf Ekle")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                }
                .onChange(of: selectedPhoto) {
                    guard let newItem = selectedPhoto else { return }
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }

                // Bilgilendirici Not
                if selectedImageData == nil {
                    Text("İsteğe bağlı: Fotoğraf ekleyebilirsin.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                //  Gönder Butonu
                Button(action: {
                    guard rating > 0 else {
                        alertMessage = "Lütfen bir puan verin "
                        showAlert = true
                        return
                    }

                
                
                       
                    
                }) {
                    Text(isSending ? "Gönderiliyor..." : "Gönder")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isSending)
            }
            .padding()
            .navigationTitle("Değerlendirme Yap")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") {
                        dismiss()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Uyarı"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
            }
        }
    }
}
