import SwiftUI
import FirebaseFirestore

struct CourseCreationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var description = ""
    @State private var videoURL = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Course Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Video URL", text: $videoURL)
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: createCourse) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Create Course")
                        }
                    }
                    .disabled(isLoading || title.isEmpty || description.isEmpty || videoURL.isEmpty)
                }
            }
            .navigationBarTitle("Create New Course", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func createCourse() {
        isLoading = true
        errorMessage = ""
        
        let newCourse = Course(id: nil, title: title, description: description, videoURL: videoURL, assignedUsers: [])
        
        let db = Firestore.firestore()
        db.collection("courses").addDocument(data: [
            "title": newCourse.title,
            "description": newCourse.description,
            "videoURL": newCourse.videoURL,
            "assignedUsers": newCourse.assignedUsers
        ]) { error in
            isLoading = false
            if let error = error {
                errorMessage = "Error creating course: \(error.localizedDescription)"
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}