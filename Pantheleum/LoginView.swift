import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isSignUp = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .padding(.bottom, 50)
            
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
            
            Button(action: {
                if isSignUp {
                    signUp()
                } else {
                    login()
                }
            }) {
                Text(isSignUp ? "Sign Up" : "Login")
                    .foregroundColor(Color.pantheleumBackground)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pantheleumBlue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: { isSignUp.toggle() }) {
                Text(isSignUp ? "Already have an account? Log in" : "Don't have an account? Sign up")
                    .foregroundColor(Color.pantheleumBlue)
            }
            .padding()
        }
        .background(
            Image("EngineeringBackground")
                .resizable()
                .opacity(colorScheme == .dark ? 0.05 : 0.1)
        )
        .foregroundColor(Color.pantheleumText)
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