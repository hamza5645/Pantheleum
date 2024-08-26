//
//  ContentView.swift
//  Pantheleum
//
//  Created by Hamza Osama on 8/26/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var showSignUp = false
    @State private var isAdmin = false
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if isLoggedIn {
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
        .onAppear(perform: checkAuthState)
    }

    func checkAuthState() {
        if let currentUser = Auth.auth().currentUser {
            UserManager.shared.getUser(uid: currentUser.uid) { result in
                switch result {
                case .success(let user):
                    self.isAdmin = user.isAdmin
                    self.isLoggedIn = true
                case .failure(let error):
                    print("Error fetching user: \(error.localizedDescription)")
                    self.isLoggedIn = false
                }
                self.isLoading = false
            }
        } else {
            self.isLoggedIn = false
            self.isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}