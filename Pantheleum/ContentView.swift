//
//  ContentView.swift
//  Pantheleum
//
//  Created by Hamza Osama on 8/26/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var showSignUp = false
    @State private var isAdmin = false

    var body: some View {
        Group {
            if isLoggedIn {
                if isAdmin {
                    AdminDashboardView(isLoggedIn: $isLoggedIn)
                } else {
                    CourseListView(isLoggedIn: $isLoggedIn)
                }
            } else {
                LoginView(isLoggedIn: $isLoggedIn, isAdmin: $isAdmin, showSignUp: $showSignUp)
                    .fullScreenCover(isPresented: $showSignUp) {
                        SignUpView(isLoggedIn: $isLoggedIn, showSignUp: $showSignUp, isAdmin: $isAdmin)
                    }
            }
        }
        .animation(.default, value: showSignUp)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}