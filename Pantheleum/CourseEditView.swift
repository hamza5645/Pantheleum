import SwiftUI
import FirebaseFirestore

struct CourseEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var course: Course
    @State private var allUsers: [User] = []
    @State private var selectedUsers: Set<String> = Set()
    @State private var showingDeleteAlert = false
    var onCourseUpdated: () -> Void
    var onCourseDeleted: () -> Void
    
    init(course: Course, onCourseUpdated: @escaping () -> Void, onCourseDeleted: @escaping () -> Void) {
        _course = State(initialValue: course)
        self.onCourseUpdated = onCourseUpdated
        self.onCourseDeleted = onCourseDeleted
    }
    
    var body: some View {
        Form {
            Section(header: Text("Course Details")) {
                TextField("Title", text: $course.title)
                TextField("Description", text: Binding(
                    get: { course.description ?? "" },
                    set: { course.description = $0.isEmpty ? nil : $0 }
                ))
                TextField("Video URL", text: $course.videoURL)
            }
            
            Section(header: Text("Assign Users")) {
                List(allUsers, id: \.id) { user in
                    MultipleSelectionRow(title: user.email, isSelected: selectedUsers.contains(user.id)) {
                        if selectedUsers.contains(user.id) {
                            selectedUsers.remove(user.id)
                        } else {
                            selectedUsers.insert(user.id)
                        }
                    }
                }
            }
            
            Section {
                Button("Save Changes") {
                    saveCourse()
                }
                
                Button("Delete Course") {
                    showingDeleteAlert = true
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Edit Course")
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Confirm Deletion"),
                message: Text("Are you sure you want to delete this course?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteCourse()
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear(perform: loadAllUsers)
    }
    
    private func loadAllUsers() {
        UserManager.shared.getAllUsers { result in
            switch result {
            case .success(let users):
                self.allUsers = users.filter { !$0.isAdmin }
                self.selectedUsers = Set(course.assignedUsers)
            case .failure(let error):
                print("Failed to fetch users: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveCourse() {
        course.assignedUsers = Array(selectedUsers)
        
        let db = Firestore.firestore()
        db.collection("courses").document(course.id).setData(course.dictionary) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                onCourseUpdated()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func deleteCourse() {
        let db = Firestore.firestore()
        db.collection("courses").document(course.id).delete { error in
            if let error = error {
                print("Error deleting course: \(error)")
            } else {
                onCourseDeleted()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}