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
    @State private var showSignUp = false
    @State private var isAdmin = false {
        didSet {
            print("Debug: ContentView isAdmin changed to \(isAdmin)")
        }
    }

    var body: some View {
        Group {
            if isLoggedIn {
                if isAdmin {
                    AdminDashboardView(isLoggedIn: $isLoggedIn)
                } else {
                    CourseListView(isLoggedIn: $isLoggedIn)
                }
            } else {
                if showSignUp {
                    SignUpView(isLoggedIn: $isLoggedIn, showSignUp: $showSignUp)
                } else {
                    LoginView(isLoggedIn: $isLoggedIn, isAdmin: $isAdmin, showSignUp: $showSignUp)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}