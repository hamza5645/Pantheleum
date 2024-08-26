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
            completion(.failure(NSError(domain: "UserManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No authenticated user found"])))
            return
        }
        
        let user = User(id: uid, email: email, isAdmin: isAdmin)
        
        db.collection("users").document(uid).setData([
            "email": user.email,
            "isAdmin": user.isAdmin
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(user))
            }
        }
    }
    
    func getUser(uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists {
                if let email = document.data()?["email"] as? String,
                   let isAdmin = document.data()?["isAdmin"] as? Bool {
                    let user = User(id: uid, email: email, isAdmin: isAdmin)
                    completion(.success(user))
                } else {
                    completion(.failure(NSError(domain: "UserManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])))
                }
            } else {
                completion(.failure(NSError(domain: "UserManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
            }
        }
    }
}