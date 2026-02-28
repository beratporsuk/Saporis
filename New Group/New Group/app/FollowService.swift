//
//  FollowService.swift
//  Saporis
//
//  Created by Berat PORSUK on 7.08.2025.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

final class FollowService {
    static let shared = FollowService()
    private let db = Firestore.firestore()
    private init() {}

    // MARK: - Helpers
    private func uid() throws -> String {
        guard let id = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FollowService", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturum açmamış."])
        }
        return id
    }

    private func followersDoc(_ uid: String) -> DocumentReference {
        db.collection("followers").document(uid) // schema: { following: [uid] }
    }

    // MARK: - Async API (önerilen)

    /// Takip et (arrayUnion)
    func follow(targetId: String) async throws {
        let me = try uid()
        guard me != targetId else { return } // self-follow yok
        let ref = followersDoc(me)

        do {
            try await ref.updateData(["following": FieldValue.arrayUnion([targetId])])
        } catch let err as NSError {
            // Belge yoksa oluştur
            if err.domain == FirestoreErrorDomain && err.code == FirestoreErrorCode.notFound.rawValue {
                try await ref.setData(["following": [targetId]], merge: true)
            } else {
                throw err
            }
        }
    }

    /// Takibi bırak (arrayRemove)
    func unfollow(targetId: String) async throws {
        let me = try uid()
        let ref = followersDoc(me)
        try await ref.updateData(["following": FieldValue.arrayRemove([targetId])])
    }

    /// Şu an takip ediyor muyum?
    func isFollowing(targetId: String) async -> Bool {
        guard let me = Auth.auth().currentUser?.uid else { return false }
        do {
            let snap = try await followersDoc(me).getDocument()
            let arr = snap.data()?["following"] as? [String] ?? []
            return arr.contains(targetId)
        } catch { return false }
    }

    /// Takip ettiklerim (tek sefer)
    func getFollowingOnce() async -> [String] {
        guard let me = Auth.auth().currentUser?.uid else { return [] }
        do {
            let snap = try await followersDoc(me).getDocument()
            return snap.data()?["following"] as? [String] ?? []
        } catch { return [] }
    }

    /// Takip ettiklerimi canlı dinle (UI için)
    @discardableResult
    func listenFollowing(onChange: @escaping ([String]) -> Void) -> ListenerRegistration? {
        guard let me = Auth.auth().currentUser?.uid else { return nil }
        return followersDoc(me).addSnapshotListener { snap, _ in
            let arr = snap?.data()?["following"] as? [String] ?? []
            onChange(arr)
        }
    }

    /// Sayaçlar: (posts sayısını başka servisten alıyorsun; burada follow tarafı)
    func followingCount(userId: String) async -> Int {
        do {
            let snap = try await followersDoc(userId).getDocument()
            return (snap.data()?["following"] as? [String])?.count ?? 0
        } catch { return 0 }
    }

    func followersCount(userId: String) async -> Int {
        do {
            let agg = try await db.collection("followers")
                .whereField("following", arrayContains: userId)
                .count.getAggregation(source: .server)
            return Int(truncating: agg.count)
        } catch { return 0 }
    }

    // MARK: - Completion köprüleri (mevcut çağrılar bozulmasın)

    func follow(targetId: String, completion: @escaping (Error?) -> Void) {
        Task {
            do { try await follow(targetId: targetId); completion(nil) }
            catch { completion(error) }
        }
    }

    func unfollow(targetId: String, completion: @escaping (Error?) -> Void) {
        Task {
            do { try await unfollow(targetId: targetId); completion(nil) }
            catch { completion(error) }
        }
    }

    func isFollowing(targetId: String, completion: @escaping (Bool) -> Void) {
        Task { completion(await isFollowing(targetId: targetId)) }
    }

    func getFollowingUsers(completion: @escaping ([String]) -> Void) {
        Task { completion(await getFollowingOnce()) }
    }
}
