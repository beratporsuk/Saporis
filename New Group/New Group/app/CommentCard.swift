//
//  CommentCard.swift
//  Saporis
//
//  Created by Berat PORSUK on 22.07.2025.
//


import SwiftUI

struct CommentCard: View {
    let comment: UserComment

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            //  Profil Fotoğrafı
            AsyncImage(url: URL(string: comment.profileImageURL ?? "")) { image in
                image.resizable()
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.3))
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            //  Yorum İçeriği
            VStack(alignment: .leading, spacing: 4) {
                Text(comment.userName)
                    .font(.subheadline)
                    .bold()

                Text(comment.text)
                    .font(.body)

                Text(comment.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

