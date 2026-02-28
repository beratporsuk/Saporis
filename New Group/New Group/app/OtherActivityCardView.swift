//
//  OtherActivityCardView.swift
//  app
//
//  Created by Berat PORSUK on 30.06.2025.
//

import SwiftUI

struct OtherActivityCardView: View {
    var body: some View {
    
            NavigationLink(destination: Text("Tüm yorumlar ve Check-in'ler")
                .bold()
                ){
                HStack{
                    
                    Text("Berat'ın Diğer yorumlarını ve check-in'lerini gör")
                        .font(.subheadline)
                        
                    Spacer()
                        
                    Text("→ 2")
                        .bold()
                        
                        
                        
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                
                
            }
            
        }
    }


#Preview {
    OtherActivityCardView()
}
