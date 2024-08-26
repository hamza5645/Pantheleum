import SwiftUI

struct AuthenticationView: View {
    @Binding var isLoggedIn: Bool
    @State private var showLogin = false
    @State private var showSignUp = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .padding(.top, 50)
            
            Spacer()
            
            Button(action: { showLogin = true }) {
                Text("Log In")
                    .foregroundColor(Color("PantheleumBackground"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("PantheleumBlue"))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: { showSignUp = true }) {
                Text("Sign Up")
                    .foregroundColor(Color("PantheleumBlue"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("PantheleumBackground"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("PantheleumBlue"), lineWidth: 1)
                    )
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView(isLoggedIn: $isLoggedIn, showLogin: $showLogin)
        }
        .fullScreenCover(isPresented: $showSignUp) {
            SignUpView(isLoggedIn: $isLoggedIn, showSignUp: $showSignUp)
        }
    }
}