import SwiftUI
import FirebaseFirestore

struct CourseEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var course: Course
    @State private var allUsers: [User] = []
    @State private var selectedUsers: Set<String> = Set()
    @State private var showingDeleteAlert = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var pdfURLs: [URL] = []
    @State private var pdfFileNames: [String] = []
    @State private var showingDocumentPicker = false
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
            
            Section(header: Text("Course PDFs")) {
                if let existingPDFs = course.pdfURLs {
                    ForEach(existingPDFs.indices, id: \.self) { index in
                        Text(URL(string: existingPDFs[index])?.lastPathComponent ?? "Unknown PDF")
                    }
                    .onDelete(perform: deletePDF)
                }
                
                ForEach(pdfFileNames.indices, id: \.self) { index in
                    Text(pdfFileNames[index])
                }
                .onDelete(perform: deleteNewPDF)
                
                Button("Add files") {
                    showingDocumentPicker = true
                }
            }
            
            Section {
                Button("Save Changes") {
                    updateCourse()
                }
                
                Button("Delete Course") {
                    showingDeleteAlert = true
                }
                .foregroundColor(.red)
            }
            
            if !errorMessage.isEmpty {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
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
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(urls: $pdfURLs, fileNames: $pdfFileNames)
        }
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
    
    func deletePDF(at offsets: IndexSet) {
        course.pdfURLs?.remove(atOffsets: offsets)
    }
    
    func deleteNewPDF(at offsets: IndexSet) {
        pdfURLs.remove(atOffsets: offsets)
        pdfFileNames.remove(atOffsets: offsets)
    }
    
    func updateCourse() {
        isLoading = true
        errorMessage = ""
        
        let group = DispatchGroup()
        var uploadedPDFURLs = course.pdfURLs ?? []
        
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
            self.updateCourseWithPDFs(pdfURLStrings: uploadedPDFURLs)
        }
    }

    func updateCourseWithPDFs(pdfURLStrings: [String]) {
        course.pdfURLs = pdfURLStrings
        course.assignedUsers = Array(selectedUsers)
        
        let db = Firestore.firestore()
        db.collection("courses").document(course.id).setData(course.dictionary) { error in
            isLoading = false
            if let error = error {
                errorMessage = "Error updating course: \(error.localizedDescription)"
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