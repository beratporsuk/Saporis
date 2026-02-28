//
//  ProtectedTab.swift
//  Saporis
//
//  Created by Berat PORSUK on 3.07.2025.
//

import SwiftUI
import FirebaseAuth

struct ProtectedTab<Content: View>: View {
    let content: Content
    @Binding var showLogin: Bool
    @AppStorage("isUserLoggedIn") var isUserLoggedIn = false

    init(content: Content, showLogin: Binding<Bool>) {
        self.content = content
        self._showLogin = showLogin
    }

    var body: some View {
        Group {
            if isUserLoggedIn {
                content
            } else {
                LoginPromptView(showLoginSheet: $showLogin)
            }
        }
    }
}

