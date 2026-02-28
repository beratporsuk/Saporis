//
//  ProfileEditView.swift
//  Saporis
//
//  Created by Berat PORSUK on 6.07.2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import UIKit

struct ProfileEditView: View {
    @State private var selectedImage: UIImage?
    @State private var imagePickerPresented = false
    @State private var isCamera = false
    @State private var uploadInProgress = false
    @State private var profilePhotoURL: String?

    @State private var fullName = ""
    @State private var username = ""
    @State private var city = ""

    @State private var showAlert = false
    @State private var alertMessage = ""

    @Environment(\.dismiss) var dismiss

    //Dışarıdan alınan callback: kayıt sonrası tetiklenir
    var onSave: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 24) {
            Text("Profil Bilgilerim")
                .font(.title2)
                .bold()

            // PROFİL FOTOĞRAFI
            ZStack {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else if let url = URL(string: profilePhotoURL ?? "") {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showImagePickerOptions()
                        } label: {
                            Image(systemName: "camera.fill")
                                .padding(8)
                                .background(.white)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        .offset(x: 6, y: 6)
                    }
                }
            }
            .frame(width: 120, height: 120)

            // FORM ALANLARI
            VStack(spacing: 16) {
                TextField("Ad Soyad", text: $fullName)
                    .textFieldStyle(.roundedBorder)

                TextField("Kullanıcı Adı", text: $username)
                    .textFieldStyle(.roundedBorder)

                TextField("Şehir", text: $city)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)

            // KAYDET BUTONU
            Button {
                saveProfileChanges()
            } label: {
                if uploadInProgress {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Kaydet")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .disabled(fullName.isEmpty || username.isEmpty)

            Spacer()
        }
        .sheet(isPresented: $imagePickerPresented) {
            ImagePicker(sourceType: isCamera ? .camera : .photoLibrary, selectedImage: $selectedImage)
        }
        .onAppear(perform: fetchCurrentUserData)
        .alert("Bilgi", isPresented: $showAlert) {
            Button("Tamam") { }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: selectedImage) {
            guard let image = selectedImage else { return }

            uploadInProgress = true
            uploadImageToFirebase(image: image) { url in
                DispatchQueue.main.async {
                    uploadInProgress = false
                    if let url = url {
                        profilePhotoURL = url
                        alertMessage = "Fotoğraf başarıyla yüklendi"
                        NotificationCenter.default.post(name: .profilePhotoUpdated, object: nil)
                    } else {
                        alertMessage = "Fotoğraf yüklenemedi."
                    }
                    showAlert = true
                }
            }
        }


    }

    // MARK: - KAMERA VE GALERİ
    private func showImagePickerOptions() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = windowScene.windows.first?.rootViewController else { return }

        let alert = UIAlertController(title: "Profil Fotoğrafı", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Fotoğraf Seç", style: .default) { _ in
            isCamera = false
            imagePickerPresented = true
        })

        alert.addAction(UIAlertAction(title: "Fotoğraf Çek", style: .default) { _ in
            isCamera = true
            imagePickerPresented = true
        })

        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))

        root.present(alert, animated: true)
    }

    // MARK: - PROFİL KAYDET
    private func saveProfileChanges() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        uploadInProgress = true

        if let image = selectedImage {
            uploadImageToFirebase(image: image) { url in
                saveUserData(uid: uid, profileURL: url)
            }
        } else {
            saveUserData(uid: uid, profileURL: profilePhotoURL)
        }
    }

    private func uploadImageToFirebase(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            alertMessage = "Görsel verisi alınamadı."
            showAlert = true
            completion(nil)
            return
        }

        let ref = Storage.storage().reference().child("profile_photos/\(UUID().uuidString).jpg")
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                alertMessage = "Fotoğraf yüklenemedi: \(error.localizedDescription)"
                showAlert = true
                uploadInProgress = false
                completion(nil)
                return
            }

            ref.downloadURL { url, error in
                if let error = error {
                    alertMessage = "URL alınamadı: \(error.localizedDescription)"
                    showAlert = true
                    uploadInProgress = false
                    completion(nil)
                    return
                }

                guard let downloadURL = url?.absoluteString else {
                    alertMessage = "URL boş geldi."
                    showAlert = true
                    uploadInProgress = false
                    completion(nil)
                    return
                }

                completion(downloadURL)
            }
        }
    }


    private func saveUserData(uid: String, profileURL: String?) {
        let db = Firestore.firestore()
        
        var updatedData: [String: Any] = [
            "fullName": fullName,
            "username": username,
            "city": city
        ]

        // Eğer yeni fotoğraf yüklendiyse profileURL boş gelmeyecektir
        if let profileURL = profileURL {
            updatedData["profilePhotoURL"] = profileURL
        }

        db.collection("users").document(uid).updateData(updatedData) { error in
            uploadInProgress = false
            if let error = error {
                alertMessage = "Kayıt hatası: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Bilgiler başarıyla güncellendi."
                showAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onSave?()
                    dismiss()
                }
            }
        }
    }


    // MARK: - VERİ ÇEK
    private func fetchCurrentUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { document, _ in
            if let data = document?.data() {
                fullName = data["fullName"] as? String ?? ""
                username = data["username"] as? String ?? ""
                city = data["city"] as? String ?? ""
                profilePhotoURL = data["profilePhotoURL"] as? String
            }
        }
    }
}



import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

