//
//  CommentsDetailsView.swift
//  Saporis
//
//  Created by Berat PORSUK on 22.07.2025.
//

import SwiftUI
import FirebaseFirestore

struct CommentsDetailsView: View {
    let venue: Venue  // Saporis tarafındaki mekan

    // Yorumlar
    @State private var saporisComments: [UserComment] = []
    @State private var googleReviews: [GoogleReview] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    //  Saporis yorumları
                    if !saporisComments.isEmpty {
                        Text("Saporis Kullanıcı Yorumları")
                            .font(.headline)

                        ForEach(saporisComments) { comment in
                            CommentCard(comment: comment)
                        }
                    }

                    //  Google yorumları
                    if !googleReviews.isEmpty {
                        Text("Google Yorumları")
                            .font(.headline)
                            .padding(.top)

                        ForEach(googleReviews) { review in
                            GoogleReviewCard(review: review)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Yorumlar")
            .onAppear {
                fetchSaporisComments()
                fetchGoogleReviews()
            }
        }
    }

    // Google yorumlarını çeken fonksiyon
    func fetchGoogleReviews() {
        guard let apiKey = Bundle.main.infoDictionary?["GooglePlacesAPIKey"] as? String else {
            print(" API anahtarı bulunamadı.")
            return
        }

        let fields = "reviews"
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(venue.googlePlaceID)&fields=\(fields)&key=\(apiKey)"

        guard let url = URL(string: urlString) else { return }

       /* URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(" Hata: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print(" Veri boş geldi, internet bağlantısı kontrol edilmeli.")
                print(" İstek atıldı: \(urlString)")

                return
            }

            do {
                let decoded = try JSONDecoder().decode(GooglePlaceDetailsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.googleReviews = decoded.result.reviews ?? []
                }
            } catch {
                print("JSON çözümleme hatası: \(error.localizedDescription)")
            }
        }.resume()*/
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(" İstek hatası: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print(" API'dan veri alınamadı, data nil döndü.")
                return
            }
            print(" Gelen veri:")
            print(String(data: data, encoding: .utf8) ?? "Boş veri")


            do {
                let decoded = try JSONDecoder().decode(GooglePlaceDetailsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.googleReviews = decoded.result.reviews ?? []
                }
            } catch {
                print(" JSON çözümleme hatası: \(error.localizedDescription)")
            }
        }.resume()

    }

    //  Firebase'den Saporis yorumlarını çeken fonksiyon
    func fetchSaporisComments() {
        let db = Firestore.firestore()

        db.collection("comments")
            .whereField("venueID", isEqualTo: venue.id)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(" Firestore yorum hatası: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                let comments = documents.compactMap { doc -> UserComment? in
                    let data = doc.data()
                    print(" Firestore'dan gelen yorum verisi:", data)


                    guard
                        let userName = data["userId"] as? String,
                        let commentText = data["content"] as? String,
                        let timestamp = data["timestamp"] as? Timestamp
                    else {
                        return nil
                    }

                    let profileImageURL = data["profileImageURL"] as? String

                    return UserComment(
                        id: doc.documentID,
                        userName: userName,
                        profileImageURL: profileImageURL,
                        text: commentText,
                        timestamp: timestamp.dateValue()
                    )
                }

                DispatchQueue.main.async {
                    self.saporisComments = comments
                }
            }
    }
}
struct UserComment: Identifiable {
    let id: String
    let userName: String
    let profileImageURL: String?
    let text: String
    let timestamp: Date
}

struct GoogleReview: Identifiable, Codable {
    var id: String { text + relativeTimeDescription }

    let authorName: String
    let profilePhotoUrl: String
    let rating: Int
    let relativeTimeDescription: String
    let text: String

    enum CodingKeys: String, CodingKey {
        case authorName = "author_name"
        case profilePhotoUrl = "profile_photo_url"
        case rating
        case relativeTimeDescription = "relative_time_description"
        case text
    }
}


struct GooglePlaceDetailsResponse: Codable {
    let result: GooglePlaceReviews

    struct GooglePlaceReviews: Codable {
        let reviews: [GoogleReview]?
    }
}



struct GoogleReviewCard: View {
    let review: GoogleReview

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 🧍 Sabit Avatar
            Image(systemName: "person.circle.fill")
                .resizable()
                .foregroundColor(.gray)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text("Google Kullanıcısı")
                    .font(.subheadline)
                    .bold()

                //  Yıldızlı puan
                HStack(spacing: 2) {
                    ForEach(0..<review.rating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }

                Text(review.text)
                    .font(.body)

                Text(review.relativeTimeDescription)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

