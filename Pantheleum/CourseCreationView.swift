import SwiftUI
import FirebaseFirestore

struct CourseCreationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var description = ""  // Keep this as String, but make it optional when creating the Course
    @State private var videoURL = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Course Details")) {
                    TextField("Title", text: $title)
                    TextField("Description (Optional)", text: $description)
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
                    .disabled(isLoading || title.isEmpty || videoURL.isEmpty)  // Remove description from this check
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
        
        let newCourse = Course(
            id: nil,
            title: title,
            description: description.isEmpty ? nil : description,  // Make it nil if empty
            videoURL: videoURL,
            assignedUsers: []
        )
        
        let db = Firestore.firestore()
        var courseData: [String: Any] = [
            "title": newCourse.title,
            "videoURL": newCourse.videoURL,
            "assignedUsers": newCourse.assignedUsers
        ]
        if let description = newCourse.description {
            courseData["description"] = description
        }
        
        db.collection("courses").addDocument(data: courseData) { error in
            isLoading = false
            if let error = error {
                errorMessage = "Error creating course: \(error.localizedDescription)"
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}