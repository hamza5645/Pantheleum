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
    @Environment(\.colorScheme) var colorScheme
    
    let courses = [
        Course(title: "Advanced Fluid Dynamics", description: "Master complex fluid flow systems"),
        Course(title: "Machine Learning for Engineers", description: "Apply ML techniques to engineering problems"),
        Course(title: "Advanced Materials Science", description: "Explore cutting-edge materials and their applications")
    ]
    
    var body: some View {
        NavigationView {
            List(courses) { course in
                NavigationLink(destination: CourseDetailView(course: course)) {
                    VStack(alignment: .leading) {
                        Text(course.title)
                            .font(.headline)
                            .foregroundColor(Color.pantheleumBlue)
                        Text(course.description)
                            .font(.subheadline)
                            .foregroundColor(Color.pantheleumText.opacity(0.7))
                    }
                }
            }
            .navigationTitle("Advanced Courses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: signOut) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(Color.pantheleumBlue)
                    }
                }
            }
        }
        .accentColor(Color.pantheleumBlue)
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