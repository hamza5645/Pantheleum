import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AdminDashboardView: View {
    @Binding var isLoggedIn: Bool
    @State private var courses: [Course] = []
    @State private var users: [User] = []
    @State private var showingAddCourse = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Courses")) {
                    ForEach(courses) { course in
                        NavigationLink(destination: CourseEditView(course: course, onCourseUpdated: loadCourses, onCourseDeleted: loadCourses)) {
                            Text(course.title)
                        }
                    }
                    .onDelete(perform: deleteCourses)
                }
                
                Section(header: Text("Users")) {
                    ForEach(users, id: \.id) { user in
                        Text(user.email)
                    }
                }
            }
            .navigationTitle("Admin Dashboard")
            .navigationBarItems(
                leading: Button("Add Course") {
                    showingAddCourse = true
                },
                trailing: Button(action: logOut) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
            )
        }
        .onAppear(perform: loadData)
        .sheet(isPresented: $showingAddCourse) {
            CourseCreationView(onCourseCreated: {
                loadCourses()
                showingAddCourse = false
            })
        }
    }

    func deleteCourses(at offsets: IndexSet) {
        let coursesToDelete = offsets.map { courses[$0] }
        let db = Firestore.firestore()
        
        for course in coursesToDelete {
            db.collection("courses").document(course.id).delete { error in
                if let error = error {
                    print("Error deleting course: \(error)")
                } else {
                    print("Course successfully deleted")
                }
            }
        }
        
        courses.remove(atOffsets: offsets)
    }

    func loadData() {
        loadCourses()
        loadUsers()
    }

    func loadCourses() {
        let db = Firestore.firestore()
        db.collection("courses").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.courses = querySnapshot?.documents.compactMap { document in
                    Course(document: document)
                } ?? []
            }
        }
    }

    func loadUsers() {
        UserManager.shared.getAllUsers { result in
            switch result {
            case .success(let fetchedUsers):
                self.users = fetchedUsers
            case .failure(let error):
                print("Failed to fetch users: \(error.localizedDescription)")
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