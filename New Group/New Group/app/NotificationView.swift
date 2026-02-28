//
//  NotificationView.swift
//  app
//
//  Created by Berat PORSUK on 3.07.2025.
//

import SwiftUI
import FirebaseAuth

struct NotificationView: View {
    @State private var notifications: [NotificationModel] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bildirimler")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            List(notifications) { notif in
                NotificationLineView(notification: notif)
            }
        }
        .padding(.horizontal)
        .onAppear(perform: loadNotifications)
    }

    func loadNotifications() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        NotificationService.shared.fetchNotifications(for: userId) { notifs in
            self.notifications = notifs
        }
    }
}

struct NotificationLineView: View {
    let notification: NotificationModel

    var body: some View {
        HStack {
            Image(systemName: "bell.badge.fill")
                .foregroundColor(.orange)
            Text(notificationTitle())
        }
        .padding(.vertical, 4)
    }

    func notificationTitle() -> String {
        switch notification.type {
        case "follow":
            return "Bir kullanıcı seni takip etti."
        case "recommendation":
            return "Sana \(notification.venueName ?? "bir yer") önerildi."
        default:
            return "Yeni bir bildirim var."
        }
    }
}
