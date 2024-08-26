import SwiftUI
import FirebaseFirestore

struct CourseEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var course: Course
    @State private var title: String
    @State private var description: String
    @State private var videoURL: String
    
    init(course: Course) {
        _course = State(initialValue: course)
        _title = State(initialValue: course.title)
        _description = State(initialValue: course.description ?? "")
        _videoURL = State(initialValue: course.videoURL)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Course Details")) {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                TextField("Video URL", text: $videoURL)
            }
            
            Button("Save Changes") {
                saveCourse()
            }
        }
        .navigationBarTitle("Edit Course", displayMode: .inline)
    }
    
    func saveCourse() {
        let updatedCourse = Course(id: course.id, title: title, description: description, videoURL: videoURL, assignedUsers: course.assignedUsers)
        let db = Firestore.firestore()
        if let id = updatedCourse.id {
            db.collection("courses").document(id).setData(updatedCourse.dictionary) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
