import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AdminDashboardView: View {
    @Binding var isLoggedIn: Bool
    @State private var courses: [Course] = []
    @State private var users: [User] = []
    @State private var showingAddCourse = false
    @State private var showingDeleteAlert = false
    @State private var courseToDelete: Course?

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Courses")) {
                    ForEach(courses) { course in
                        HStack {
                            NavigationLink(destination: CourseEditView(course: course, onCourseUpdated: loadCourses)) {
                                Text(course.title)
                            }
                            Spacer()
                            Button(action: {
                                courseToDelete = course
                                showingDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
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
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Confirm Deletion"),
                message: Text("Are you sure you want to delete this course?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let course = courseToDelete {
                        deleteCourse(course)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    func deleteCourse(_ course: Course) {
        let db = Firestore.firestore()
        db.collection("courses").document(course.id).delete { error in
            if let error = error {
                print("Error deleting course: \(error)")
            } else {
                loadCourses()
            }
        }
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