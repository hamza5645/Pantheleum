import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showSignUp = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    VStack(spacing: 30) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        
                        VStack(spacing: 20) {
                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                            
                            SecureField("Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: login) {
                            Text("Log In")
                                .foregroundColor(Color("PantheleumBackground"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("PantheleumBlue"))
                                .cornerRadius(10)
                        }
                        
                        Button("Don't have an account? Sign Up") {
                            showSignUp = true
                        }
                        .foregroundColor(Color("PantheleumBlue"))
                    }
                    .frame(width: min(geometry.size.width - 40, 340))
                    .padding(.vertical, 20)
                    
                    Spacer()
                }
                .frame(width: geometry.size.width)
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showSignUp) {
            SignUpView(isLoggedIn: $isLoggedIn, showSignUp: $showSignUp)
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true
            }
        }
    }
}