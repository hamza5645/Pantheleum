import SwiftUI

struct Course: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

struct CourseListView: View {
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
        }
    }
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