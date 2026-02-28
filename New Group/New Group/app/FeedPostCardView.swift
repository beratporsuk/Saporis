//
//  FeedPostCardView.swift
//  app
//
//  Created by Berat PORSUK on 30.06.2025.
//
/*
import SwiftUI

struct FeedPostCardView: View {
    
   let username: String
   
   let placeName: String
   let comment: String
   let timeEgo: String
   let imageName: String? //optional

    @AppStorage("profileImageData") var profileImageData: Data = Data()
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8 ){
            //kullanıcı ve zaman
            HStack {
                if let uiImage = UIImage(data: profileImageData) {
                    Image(uiImage: uiImage)
                    .resizable()
                   .scaledToFill()
                   .frame(width: 36, height: 36)
                   .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                       .frame(width: 36, height: 36)
                       .foregroundColor(.gray)
                    
                }
                     
                
                
                VStack(alignment: .leading) {
                    Text(username)
                        .font(.headline)
                    Text(timeEgo)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                }
                Spacer()
                
                }
            //mekan
            
            Text(placeName)
                .font(.subheadline)
                .foregroundColor(.blue)
            
            // yorum
            
            Text(comment)
                .font(.body)
            
            //fotograf? (optional)
            
            if let imageName = imageName {
                Image(imageName).resizable()
                    .scaledToFill()
                    .scaledToFit()
                   // .frame(height: 350)
                    
                    .clipped()
                    .cornerRadius(10)
                
            }
            HStack {
                Image(systemName: "heart")
                Spacer()
                Image(systemName: "bubble.right")
                
                
            }
            .padding(.top, 4)
            .foregroundColor(.gray)
            
            
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        
        
        
    }
}*/
import SwiftUI

struct FeedPostCardView: View {
    let post: PostModel
    let user: UserModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Kullanıcı bilgisi
            HStack(spacing: 10) {
                if let imageURL = user?.profilePhotoURL,
                   let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.gray)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(user?.username ?? post.userId)
                        .font(.headline)

                    Text(post.timestamp, style: .relative) // örn: 1 saat önce
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            // Mekan adı
            Text(post.venueName)
                .font(.subheadline)
                .foregroundColor(.blue)

            // Yorum
            Text(post.commentText)
                .font(.body)

            // Gönderi görseli (PostModel artık imageURLs array tutuyor)
            if let url = post.firstImageURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .clipped()
                .cornerRadius(10)
            } else {
                // Görsel yoksa sade placeholder
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }

            // İkonlar
            HStack {
                Image(systemName: "heart")
                Spacer()
                Image(systemName: "bubble.right")
            }
            .padding(.top, 4)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
