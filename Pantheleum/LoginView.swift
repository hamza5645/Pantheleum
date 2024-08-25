import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isSignUp = false
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(isSignUp ? "Sign Up" : "Login") {
                if isSignUp {
                    signUp()
                } else {
                    login()
                }
            }
            .padding()
            
            Button(isSignUp ? "Already have an account? Log in" : "Don't have an account? Sign up") {
                isSignUp.toggle()
                errorMessage = ""
            }
            .padding()
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            } else {
                print("Login successful")
                isLoggedIn = true
            }
        }
    }
    
    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Signup error: \(error.localizedDescription)")
                print("Full error object: \(error)")
                errorMessage = error.localizedDescription
            } else {
                print("Signup successful")
                isLoggedIn = true
            }
        }
    }
}