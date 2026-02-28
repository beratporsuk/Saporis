//
//  SpalashScreenView.swift
//  app
//
//  Created by Berat PORSUK on 29.06.2025.
//

import SwiftUI

struct SpalashScreenView: View {
    @State private var isActive = false
    var body : some View {
       if isActive {
            MainTabView()
           
        }else {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                VStack(spacing: 20){
                    Text("SAPORIS")
                        .font(.system(size: 48, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    Text("Your Plate, Your Voice")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    
                    
                }
            }.onAppear(){
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    withAnimation{
                        isActive=true
                    }
                    
                }
                
            }
        }
    }
    
}


#Preview{
    SpalashScreenView()
}


