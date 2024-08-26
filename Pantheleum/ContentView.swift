//
//  ContentView.swift
//  Pantheleum
//
//  Created by Hamza Osama on 8/26/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @State private var isLoggedIn = false
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
                LoginView(isLoggedIn: $isLoggedIn, isAdmin: $isAdmin)
            }
        }
        .onAppear(perform: checkAuthState)
    }

    private func checkAuthState() {
        if let user = Auth.auth().currentUser {
            isLoggedIn = true
            checkAdminStatus(userId: user.uid)
        } else {
            isLoggedIn = false
            isAdmin = false
        }
        isLoading = false
    }

    private func checkAdminStatus(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                if let isAdmin = document.data()?["isAdmin"] as? Bool {
                    self.isAdmin = isAdmin
                } else {
                    self.isAdmin = false
                }
            } else {
                print("User document does not exist")
                self.isAdmin = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}