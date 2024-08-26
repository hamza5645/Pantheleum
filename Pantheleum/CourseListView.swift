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
            
            Text(course.description)
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
                    Text(course.title)
                }
            }
            .navigationTitle("My Courses")
            .navigationBarItems(trailing: Button("Log Out") {
                logOut()
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
                    courses = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: Course.self)
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
}