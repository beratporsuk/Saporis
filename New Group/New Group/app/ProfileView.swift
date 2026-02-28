//
//  ProfileView.swift
//  app
//
//  Created by Berat PORSUK on 29.06.2025.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import MapKit

// Yönlendirme rotaları
enum ProfileRoute: String, Hashable, Equatable {
    case settings
    case notifications
    case recommendedVenues
}

struct ProfileView: View {
    @Binding var showLogin: Bool
    @AppStorage("isUserLoggedIn") var isUserLoggedIn: Bool = false

    @State private var userCheckIns: [CheckIn] = []
    @State private var userComments: [Comment] = []
    @State private var userFavorites: [Favorite] = []
    @State private var userPosts: [PostModel] = []

    @State private var userData: UserModel? = nil
    @State private var path: [ProfileRoute] = []

    let mockLocations = [
        CLLocationCoordinate2D(latitude: 39.925533, longitude: 32.866287), // Ankara
        CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),     // İstanbul
        CLLocationCoordinate2D(latitude: 38.4192, longitude: 27.1287)      // İzmir
    ]

    var body: some View {
        NavigationStack(path: $path) {
            if isUserLoggedIn {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        topBar
                        minimapView
                        userInfoSection
                        Divider()

                        recommendedVenuesCard
                        Divider()

                        OtherActivityCardView()
                        ProfilAkisKutucuklari()

                        Divider()

                        // Son check-inler
                        if !userCheckIns.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("📍 Son Check-in'ler")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(userCheckIns.prefix(5)) { checkIn in
                                    HStack {
                                        Text(checkIn.venueName)
                                            .font(.subheadline)
                                        Spacer()
                                        Text(dateFormatter.string(from: checkIn.timestamp))
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        // Yorumlar
                        if !userComments.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("📝 Yorumların")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(userComments.prefix(5)) { comment in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(comment.venueName)
                                            .font(.subheadline)
                                            .bold()
                                        Text(comment.content)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        // Favoriler
                        if !userFavorites.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("❤️ Favori Mekanların")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(userFavorites.prefix(5)) { favorite in
                                    Text(favorite.venueName)
                                        .font(.subheadline)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .notifications:
                        NotificationView()
                    case .settings:
                        SettingsView(
                            showLogin: $showLogin,
                            onProfileUpdated: {
                                fetchUserData()
                            }
                        )
                    case .recommendedVenues:
                        RecommendedVenuesDetailView(venues: MockData.venues.filter { $0.isRecommended })
                    }
                }
                .onAppear {
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    fetchUserData()

                    fetchUserCheckIns(userId: uid) { self.userCheckIns = $0 }
                    fetchUserComments(userId: uid) { self.userComments = $0 }
                    fetchUserFavorites(userId: uid) { self.userFavorites = $0 }
                }
            } else {
                Color.clear
                    .onAppear { showLogin = true }
            }
        }
        .onAppear {
            if Auth.auth().currentUser != nil {
                isUserLoggedIn = true
                fetchUserData()
            } else {
                isUserLoggedIn = false
                showLogin = true
            }

            NotificationCenter.default.addObserver(forName: .profilePhotoUpdated, object: nil, queue: .main) { _ in
                fetchUserData()
            }
        }
    }

    // MARK: - UI Blocks

    private var topBar: some View {
        ZStack {
            HStack {
                Text("Saporis")
                    .font(.title)
                    .bold()

                Spacer()

                Button {
                    path.append(.notifications)
                } label: {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                }

                Button {
                    path.append(.settings)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.black)
                }
            }

            Text("Profil")
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .padding(.horizontal)
        .frame(height: 40)
    }

    private var minimapView: some View {
        MiniMapView(venues: MockData.venues)
            .cornerRadius(12)
            .frame(height: 190)
            .frame(maxWidth: .infinity)
            .clipped()
    }

    private var userInfoSection: some View {
        HStack(spacing: 12) {
            profileImage

            VStack(alignment: .leading, spacing: 4) {
                Text(userData?.fullName ?? "Yükleniyor...")
                    .font(.headline)

                Text("@\(userData?.username ?? "kullanici")")
                    .foregroundColor(.gray)

                Text(userData?.city ?? "Türkiye")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            Spacer()

            VStack {
                Text("Takipçi")
                Text("28").bold()
            }

            VStack {
                Text("Takip")
                Text("29").bold()
            }
        }
        .padding(.horizontal)
    }

    private var profileImage: some View {
        Group {
            if let urlString = userData?.profilePhotoURL,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 72, height: 72)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.crop.circle.badge.exclam")
                            .resizable()
                            .frame(width: 72, height: 72)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 72, height: 72)
                    .foregroundColor(.gray)
            }
        }
    }

    private var recommendedVenuesCard: some View {
        Button(action: {
            path.append(.recommendedVenues)
        }) {
            HStack {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                Text("Önerdiğim Mekanlar")
                    .font(.body)
                    .foregroundColor(.blue)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    // MARK: - Fetch User Data

    private func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists,
               let data = document.data() {
                self.userData = UserModel(
                    uid: uid,
                    email: data["email"] as? String ?? "",
                    username: data["username"] as? String ?? "",
                    fullName: data["fullName"] as? String ?? "",
                    city: data["city"] as? String ?? "Türkiye",
                    profilePhotoURL: data["profilePhotoURL"] as? String ?? ""
                )
            } else {
                print("Veri çekilemedi: \(error?.localizedDescription ?? "Bilinmeyen hata")")
            }
        }
    }

    // MARK: - Fetch User Activity (TEMP / Compile-Safe)
    // Bu fonksiyonlar şimdilik compile hatalarını çözer.
    // Modellerini (CheckIn/Comment/Favorite) atınca burayı gerçek mapping ile dolduracağız.

    private func fetchUserCheckIns(userId: String, completion: @escaping ([CheckIn]) -> Void) {
        Firestore.firestore()
            .collection("checkins") // TODO: kendi collection adın farklıysa değiştir
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("fetchUserCheckIns error:", error.localizedDescription)
                    completion([])
                    return
                }

                print("checkins docs:", snapshot?.documents.count ?? 0)
                // TODO: CheckIn modeline map
                completion([])
            }
    }

    private func fetchUserComments(userId: String, completion: @escaping ([Comment]) -> Void) {
        Firestore.firestore()
            .collection("comments") // TODO: kendi collection adın farklıysa değiştir
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("fetchUserComments error:", error.localizedDescription)
                    completion([])
                    return
                }

                print("comments docs:", snapshot?.documents.count ?? 0)
                // TODO: Comment modeline map
                completion([])
            }
    }

    private func fetchUserFavorites(userId: String, completion: @escaping ([Favorite]) -> Void) {
        Firestore.firestore()
            .collection("favorites") // TODO: kendi collection adın farklıysa değiştir
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("fetchUserFavorites error:", error.localizedDescription)
                    completion([])
                    return
                }

                print("favorites docs:", snapshot?.documents.count ?? 0)
                // TODO: Favorite modeline map
                completion([])
            }
    }

    // MARK: - Date Formatter

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

/*

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import MapKit

enum ProfileRoute: String, Hashable, Equatable {
    case settings
    case notifications
    case recommendedVenues
}

struct ProfileView: View {
    @Binding var showLogin: Bool
    @AppStorage("isUserLoggedIn") var isUserLoggedIn: Bool = false

    @State private var userCheckIns: [CheckIn] = []
    @State private var userComments: [Comment] = []
    @State private var userFavorites: [Favorite] = []
    @State private var userPosts: [PostModel] = []

    @State private var userData: UserModel? = nil
    @State private var path: [ProfileRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            if isUserLoggedIn {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        topBar
                        minimapView
                        userInfoSection
                        Divider()
                        recommendedVenuesCard
                        Divider()

                        if !userPosts.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\u{1F4F7} Diğer Gönderilerin")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(userPosts, id: \ .postId) { post in
                                    FeedPostCardView(
                                        username: userData?.username ?? "kullanici",
                                        placeName: post.venueName,
                                        comment: post.commentText,
                                        timeEgo: timeAgoSinceDate(post.timestamp),
                                        imageName: nil
                                    )
                                }
                            }
                        }

                        OtherActivityCardView()
                        ProfilAkisKutucuklari()
                        Divider()

                        if !userCheckIns.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\u{1F4CD} Son Check-in'ler")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(userCheckIns.prefix(5)) { checkIn in
                                    HStack {
                                        Text(checkIn.venueName)
                                            .font(.subheadline)
                                        Spacer()
                                        Text(dateFormatter.string(from: checkIn.timestamp))
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        if !userComments.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\u{1F4DD} Yorumların")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(userComments.prefix(5)) { comment in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(comment.venueName)
                                            .font(.subheadline)
                                            .bold()
                                        Text(comment.content)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        if !userFavorites.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\u{2764}\u{FE0F} Favori Mekanların")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(userFavorites.prefix(5)) { favorite in
                                    Text(favorite.venueName)
                                        .font(.subheadline)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .notifications:
                        NotificationView()
                    case .settings:
                        SettingsView(showLogin: $showLogin) {
                            fetchUserData()
                        }
                    case .recommendedVenues:
                        RecommendedVenuesDetailView(venues: MockData.venues.filter { $0.isRecommended })
                    }
                }
                .onAppear {
                    if let uid = Auth.auth().currentUser?.uid {
                        fetchUserData()
                        fetchUserCheckIns(userId: uid) { self.userCheckIns = $0 }
                        fetchUserComments(userId: uid) { self.userComments = $0 }
                        fetchUserFavorites(userId: uid) { self.userFavorites = $0 }
                        fetchAllPosts(userId: uid)
                    }
                }
            } else {
                Color.clear
                    .onAppear { showLogin = true }
            }
        }
        .onAppear {
            if Auth.auth().currentUser != nil {
                isUserLoggedIn = true
                fetchUserData()
            } else {
                isUserLoggedIn = false
                showLogin = true
            }

            NotificationCenter.default.addObserver(forName: .profilePhotoUpdated, object: nil, queue: .main) { _ in
                fetchUserData()
            }
        }
    }

    private func fetchAllPosts(userId: String) {
        PostService().fetchAllPosts(for: userId) { posts in
            self.userPosts = posts
        }
    }

    private var topBar: some View {
        ZStack {
            HStack {
                Text("Saporis")
                    .font(.title)
                    .bold()
                Spacer()
                Button { path.append(.notifications) } label: {
                    Image(systemName: "bell.fill").foregroundColor(.orange)
                }
                Button { path.append(.settings) } label: {
                    Image(systemName: "gearshape.fill").foregroundColor(.black)
                }
            }
            Text("Profil")
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .padding(.horizontal)
        .frame(height: 40)
    }

    private var minimapView: some View {
        MiniMapView(venues: MockData.venues)
            .cornerRadius(12)
            .frame(height: 190)
            .frame(maxWidth: .infinity)
            .clipped()
    }

    private var userInfoSection: some View {
        HStack(spacing: 12) {
            profileImage
            VStack(alignment: .leading, spacing: 4) {
                Text(userData?.fullName ?? "Yükleniyor...").font(.headline)
                Text("@\(userData?.username ?? "kullanici")").foregroundColor(.gray)
                Text(userData?.city ?? "Türkiye").font(.caption).foregroundColor(.orange)
            }
            Spacer()
            VStack { Text("Takipçi"); Text("28").bold() }
            VStack { Text("Takip"); Text("29").bold() }
        }
        .padding(.horizontal)
    }

    private var profileImage: some View {
        Group {
            if let urlString = userData?.profilePhotoURL,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: 72, height: 72)
                    case .success(let image):
                        image.resizable().scaledToFill().frame(width: 72, height: 72).clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.crop.circle.badge.exclam")
                            .resizable().frame(width: 72, height: 72).foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable().frame(width: 72, height: 72).foregroundColor(.gray)
            }
        }
    }

    private func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists,
               let data = document.data() {
                self.userData = UserModel(
                    uid: uid,
                    email: data["email"] as? String ?? "",
                    username: data["username"] as? String ?? "",
                    fullName: data["fullName"] as? String ?? "",
                    city: data["city"] as? String ?? "Türkiye",
                    profilePhotoURL: data["profilePhotoURL"] as? String ?? ""
                )
            } else {
                print("Veri çekilemedi: \(error?.localizedDescription ?? "Bilinmeyen hata")")
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    private var recommendedVenuesCard: some View {
        Button(action: {
            path.append(.recommendedVenues)
        }) {
            HStack {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                Text("Önerdiğim Mekanlar")
                    .font(.body)
                    .foregroundColor(.blue)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    func timeAgoSinceDate(_ date: Date, numericDates: Bool = false) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now

        let components: DateComponents = calendar.dateComponents(
            [.minute, .hour, .day, .weekOfYear, .month, .year],
            from: earliest,
            to: latest
        )

        if let year = components.year, year >= 2 {
            return "\(year) yıl önce"
        } else if let year = components.year, year >= 1 {
            return numericDates ? "1 yıl önce" : "Geçen yıl"
        } else if let month = components.month, month >= 2 {
            return "\(month) ay önce"
        } else if let month = components.month, month >= 1 {
            return numericDates ? "1 ay önce" : "Geçen ay"
        } else if let week = components.weekOfYear, week >= 2 {
            return "\(week) hafta önce"
        } else if let week = components.weekOfYear, week >= 1 {
            return numericDates ? "1 hafta önce" : "Geçen hafta"
        } else if let day = components.day, day >= 2 {
            return "\(day) gün önce"
        } else if let day = components.day, day >= 1 {
            return numericDates ? "1 gün önce" : "Dün"
        } else if let hour = components.hour, hour >= 2 {
            return "\(hour) saat önce"
        } else if let hour = components.hour, hour >= 1 {
            return numericDates ? "1 saat önce" : "1 saat önce"
        } else if let minute = components.minute, minute >= 2 {
            return "\(minute) dakika önce"
        } else if let minute = components.minute, minute >= 1 {
            return numericDates ? "1 dakika önce" : "1 dakika önce"
        } else {
            return "Şimdi"
        }
    }


}
*/
