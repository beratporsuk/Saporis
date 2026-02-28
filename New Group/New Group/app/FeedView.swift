//
//  FeedView.swift
//  app
//
//  Created by Berat PORSUK on 30.06.2025.
//
import SwiftUI
import FirebaseAuth

struct FeedView: View {
    @AppStorage("isUserLoggedIn") var isUserLoggedIn: Bool = false
    @State private var showLoginSheet = false
    @State private var showLoginAlert = false

    // [(Post, User)] ikilisi
    @State private var feedItems: [(PostModel, UserModel?)] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // Top bar gibi özel header varsa onu ekle
                    FeedTopBarView()
                        .padding(.top)

                    // Gönderiler
                    ForEach(feedItems, id: \.0.id) { post, user in
                        FeedPostCardView(post: post, user: user)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            if Auth.auth().currentUser == nil {
                showLoginAlert = true
            } else {
                loadFeed()
            }
        }
        .alert("Devam etmek için giriş yapmalısınız.", isPresented: $showLoginAlert) {
            Button("Vazgeç", role: .cancel) {}
            Button("Giriş Yap") {
                showLoginSheet = true
            }
        }
        .fullScreenCover(isPresented: $showLoginSheet) {
            AuthView(showLogin: $showLoginSheet)
        }
    }

    func loadFeed() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        PostService.shared.fetchFeedPosts(for: userId) { posts in
            var combined: [(PostModel, UserModel?)] = []
            let dispatchGroup = DispatchGroup()

            for post in posts {
                dispatchGroup.enter()

                UserService.shared.fetchUser(with: post.userId) { user in
                    combined.append((post, user))
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                // Zaman sırasına göre sıralama
                self.feedItems = combined.sorted(by: { $0.0.timestamp > $1.0.timestamp })
            }
        }
    }
}
