import Foundation
import FirebaseAuth
import FirebaseFirestore

struct User: Codable {
    let id: String
    let email: String
    var isAdmin: Bool
}

class UserManager {
    static let shared = UserManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func createUser(email: String, isAdmin: Bool = false, completion: @escaping (Result<User, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Debug: No authenticated user found")
            completion(.failure(NSError(domain: "UserManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No authenticated user found"])))
            return
        }
        
        let user = User(id: uid, email: email, isAdmin: isAdmin)
        
        db.collection("users").document(uid).setData([
            "email": user.email,
            "isAdmin": user.isAdmin
        ]) { error in
            if let error = error {
                print("Debug: Error creating user in Firestore: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Debug: User successfully created in Firestore: \(user)")
                completion(.success(user))
            }
        }
    }
    
    func getUser(uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { (document, error) in
            if let error = error {
                print("Debug: Error fetching user from Firestore: \(error.localizedDescription)")
                completion(.failure(error))
            } else if let document = document, document.exists {
                if let email = document.data()?["email"] as? String,
                   let isAdmin = document.data()?["isAdmin"] as? Bool {
                    let user = User(id: uid, email: email, isAdmin: isAdmin)
                    print("Debug: User successfully fetched from Firestore: \(user)")
                    completion(.success(user))
                } else {
                    print("Debug: Invalid user data in Firestore")
                    completion(.failure(NSError(domain: "UserManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])))
                }
            } else {
                print("Debug: User not found in Firestore")
                completion(.failure(NSError(domain: "UserManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
            }
        }
    }
    
    func getAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        db.collection("users").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Debug: Error fetching all users: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                let users = querySnapshot?.documents.compactMap { document -> User? in
                    let data = document.data()
                    guard let email = data["email"] as? String,
                          let isAdmin = data["isAdmin"] as? Bool else {
                        print("Debug: Invalid user data for document ID: \(document.documentID)")
                        return nil
                    }
                    return User(id: document.documentID, email: email, isAdmin: isAdmin)
                } ?? []
                print("Debug: Successfully fetched \(users.count) users")
                completion(.success(users))
            }
        }
    }
}