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
    @State private var pdfURLs: [URL] = []
    @State private var pdfFileNames: [String] = []
    @State private var showingDocumentPicker = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Course Details")) {
                    TextField("Title", text: $title)
                    TextField("Description (Optional)", text: $description)
                    TextField("Video URL from Firebase Storage", text: $videoURL)
                }
                
                Section(header: Text("Course Material (Optional)")) {
                    ForEach(pdfFileNames.indices, id: \.self) { index in
                        Text(pdfFileNames[index])
                    }
                    .onDelete(perform: deletePDF)
                    
                    Button("Select files") {
                        showingDocumentPicker = true
                    }
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
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPicker(urls: $pdfURLs, fileNames: $pdfFileNames)
            }
        }
    }
    
    func deletePDF(at offsets: IndexSet) {
        pdfURLs.remove(atOffsets: offsets)
        pdfFileNames.remove(atOffsets: offsets)
    }
    
    func createCourse() {
        isLoading = true
        errorMessage = ""
        
        let group = DispatchGroup()
        var uploadedPDFURLs: [String] = []
        
        for (index, pdfURL) in pdfURLs.enumerated() {
            group.enter()
            guard let pdfData = try? Data(contentsOf: pdfURL) else {
                errorMessage = "Failed to read PDF data"
                isLoading = false
                return
            }
            
            StorageManager.shared.uploadPDF(data: pdfData, fileName: pdfFileNames[index]) { result in
                switch result {
                case .success(let pdfURLString):
                    uploadedPDFURLs.append(pdfURLString)
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.errorMessage = "Error uploading PDF: \(error.localizedDescription)"
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.createCourseWithPDFs(pdfURLStrings: uploadedPDFURLs)
        }
    }

    func createCourseWithPDFs(pdfURLStrings: [String]) {
        let newCourse = Course(
            title: title,
            description: description.isEmpty ? nil : description,
            videoURL: videoURL,
            pdfURLs: pdfURLStrings,
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
