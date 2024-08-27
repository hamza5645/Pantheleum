import SwiftUI
import FirebaseFirestore

struct CourseEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var course: Course
    @State private var title: String
    @State private var description: String
    @State private var videoURL: String
    @State private var showingDeleteAlert = false
    var onCourseUpdated: () -> Void
    var onCourseDeleted: () -> Void
    
    init(course: Course, onCourseUpdated: @escaping () -> Void, onCourseDeleted: @escaping () -> Void) {
        _course = State(initialValue: course)
        _title = State(initialValue: course.title)
        _description = State(initialValue: course.description ?? "")
        _videoURL = State(initialValue: course.videoURL)
        self.onCourseUpdated = onCourseUpdated
        self.onCourseDeleted = onCourseDeleted
    }
    
    var body: some View {
        Form {
            Section(header: Text("Course Details")) {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                TextField("Video URL", text: $videoURL)
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
    }
    
    func saveCourse() {
        let updatedCourse = Course(id: course.id, title: title, description: description.isEmpty ? nil : description, videoURL: videoURL, assignedUsers: course.assignedUsers)
        let db = Firestore.firestore()
        db.collection("courses").document(updatedCourse.id).setData(updatedCourse.dictionary) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                onCourseUpdated()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func deleteCourse() {
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