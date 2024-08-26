import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AdminDashboardView: View {
    @Binding var isLoggedIn: Bool
    @State private var courses: [Course] = []
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Admin Dashboard")
                    .font(.largeTitle)
                    .padding()
                
                // Add your admin dashboard content here
                
                Button("Debug: Print All Users") {
                    debugPrintAllUsers()
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            .navigationBarItems(trailing: Button("Log Out") {
                logOut()
            })
        }
        .onAppear(perform: loadCourses)
    }
    
    func loadCourses() {
        // Implement course loading logic
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func debugPrintAllUsers() {
        UserManager.shared.getAllUsers { result in
            switch result {
            case .success(let users):
                print("Debug: All users in the database:")
                for user in users {
                    print("User ID: \(user.id), Email: \(user.email), Is Admin: \(user.isAdmin)")
                }
            case .failure(let error):
                print("Debug: Failed to fetch users: \(error.localizedDescription)")
            }
        }
    }
}