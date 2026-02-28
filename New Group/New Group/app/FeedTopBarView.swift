//
//  FeedTopBarView.swift
//  app
//
//  Created by Berat PORSUK on 30.06.2025.
//

import SwiftUI

struct FeedTopBarView: View {
    
    @State var isNotificationViewOpen = false
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .shadow(color: .gray.opacity(0.2), radius: 4, y: 2)
                .edgesIgnoringSafeArea(.top)
                .frame(height: 80)
            //sayfa yeri
            Text("Akış")
                .font(.subheadline)
                .fontWeight(.bold)
            HStack {
                HStack(spacing: 8) {
                    
                    Image("logoic")
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("Saporis")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .padding(.horizontal,10)
                Spacer()
                
                //Bildirimikonu
                
                Button(action: {
                    isNotificationViewOpen = true
                }) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                }
                .sheet(isPresented: $isNotificationViewOpen) {
                    NotificationView()
                }
                .padding(.horizontal, 20)
                .padding(.vertical)
                
            }
            
            
        }
        
        
    }
    
}


