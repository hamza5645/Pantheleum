//
//  ContentView.swift
//  Pantheleum
//
//  Created by Hamza Osama on 8/26/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var isAdmin = false

    var body: some View {
        if isLoggedIn {
            if isAdmin {
                AdminDashboardView(isLoggedIn: $isLoggedIn)
            } else {
                CourseListView(isLoggedIn: $isLoggedIn)
            }
        } else {
            LoginView(isLoggedIn: $isLoggedIn, isAdmin: $isAdmin)
        }
    }

    init() {
        // Check if user is already logged in
        if let user = Auth.auth().currentUser {
            isLoggedIn = true
            checkAdminStatus(userId: user.uid)
        }
    }

    private func checkAdminStatus(userId: String) {
        // Here you would typically check your database to see if the user is an admin
        // For this example, we'll just set it to false
        isAdmin = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}