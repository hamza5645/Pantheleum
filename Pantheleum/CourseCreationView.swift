import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import UIKit

struct CourseCreationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var description = ""
    @State private var videoURL = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    var onCourseCreated: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Course Details")) {
                    TextField("Title", text: $title)
                    TextField("Description (Optional)", text: $description)
                    TextField("Video URL from Firebase Storage", text: $videoURL)
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
                    .disabled(isLoading || title.isEmpty || videoURL.isEmpty)
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
            title: title,
            description: description.isEmpty ? nil : description,
            videoURL: videoURL,
            assignedUsers: []
        )
        
        let db = Firestore.firestore()
        db.collection("courses").addDocument(data: newCourse.dictionary) { error in
            isLoading = false
            if let error = error {
                errorMessage = "Error creating course: \(error.localizedDescription)"
            } else {
                onCourseCreated()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}