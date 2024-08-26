import SwiftUI
import FirebaseFirestore

struct CourseCreationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var description = ""
    @State private var videoURL = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Course Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Video URL", text: $videoURL)
                }
                
                Button("Create Course") {
                    createCourse()
                }
            }
            .navigationBarTitle("Create New Course", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func createCourse() {
        let newCourse = Course(id: nil, title: title, description: description, videoURL: videoURL, assignedUsers: [])
        let db = Firestore.firestore()
        db.collection("courses").addDocument(data: newCourse.dictionary) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}