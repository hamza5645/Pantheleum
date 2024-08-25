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
    
    init() {
        _isLoggedIn = State(initialValue: Auth.auth().currentUser != nil)
    }
    
    var body: some View {
        if isLoggedIn {
            CourseListView(isLoggedIn: $isLoggedIn)
        } else {
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}