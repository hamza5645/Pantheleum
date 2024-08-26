import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AdminDashboardView: View {
    @Binding var isLoggedIn: Bool
    @State private var courses: [Course] = []
    @State private var showingCourseCreation = false
    @State private var refreshTrigger = false

    var body: some View {
        NavigationView {
            List {
                ForEach(courses) { course in
                    NavigationLink(destination: CourseEditView(course: course)) {
                        Text(course.title)
                    }
                }
            }
            .navigationTitle("Admin Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Log Out") {
                        logOut()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Course") {
                        showingCourseCreation = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingCourseCreation) {
            CourseCreationView(onCourseCreated: {
                refreshTrigger.toggle()
            })
        }
        .onAppear(perform: loadCourses)
        .onChange(of: refreshTrigger) { _ in loadCourses() }
    }

    func loadCourses() {
        let db = Firestore.firestore()
        db.collection("courses").getDocuments { (querySnapshot, error) in
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