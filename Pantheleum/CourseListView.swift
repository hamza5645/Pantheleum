import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CourseDetailView: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(course.title)
                .font(.title)
                .foregroundColor(Color.pantheleumBlue)
            
            Text(course.description ?? "")
                .font(.body)
            
            Text("Course Content")
                .font(.headline)
                .padding(.top)
            
            Text("This is where you would display the course content, such as video lectures, reading materials, and interactive exercises.")
                .font(.body)
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(Color.pantheleumText)
    }
}

struct CourseListView: View {
    @Binding var isLoggedIn: Bool
    @State private var courses: [Course] = []
    
    var body: some View {
        NavigationView {
            List(courses) { course in
                NavigationLink(destination: CourseDetailView(course: course)) {
                    VStack(alignment: .leading) {
                        Text(course.title)
                            .font(.headline)
                        if let description = course.description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("My Courses")
            .navigationBarItems(trailing: Button(action: logOut) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
            })
            .onAppear(perform: loadAssignedCourses)
        }
    }
    
    func loadAssignedCourses() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("courses")
            .whereField("assignedUsers", arrayContains: uid)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.courses = querySnapshot?.documents.compactMap { document in
                        Course(document: document)
                    } ?? []
                }
            }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func checkAdminStatus() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Debug: No authenticated user found")
            return
        }
        UserManager.shared.getUser(uid: uid) { result in
            switch result {
            case .success(let user):
                print("Debug: Current user isAdmin: \(user.isAdmin)")
            case .failure(let error):
                print("Debug: Error fetching user: \(error.localizedDescription)")
            }
        }
    }
}