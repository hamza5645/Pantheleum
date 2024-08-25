import SwiftUI
import FirebaseAuth

struct Course: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

struct CourseDetailView: View {
    let course: Course
    
    var body: some View {
        VStack {
            Text(course.title)
                .font(.title)
            Text(course.description)
                .padding()
            // Here you would add video player or course content
            Text("Course content goes here")
        }
    }
}

struct CourseListView: View {
    @Binding var isLoggedIn: Bool
    
    let courses = [
        Course(title: "Swift for Beginners", description: "Learn the basics of Swift programming"),
        Course(title: "Advanced SwiftUI", description: "Master SwiftUI and build complex apps")
    ]
    
    var body: some View {
        NavigationView {
            List(courses) { course in
                NavigationLink(destination: CourseDetailView(course: course)) {
                    VStack(alignment: .leading) {
                        Text(course.title)
                            .font(.headline)
                        Text(course.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Courses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sign Out") {
                        signOut()
                    }
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}