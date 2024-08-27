import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import AVKit

struct CourseDetailView: View {
    let course: Course
    @State private var player: AVPlayer?
    @State private var isFullScreen = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(course.title)
                .font(.title)
                .foregroundColor(Color.pantheleumBlue)
            
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 200)
                    .onTapGesture {
                        isFullScreen = true
                    }
            } else {
                Text("Loading video...")
            }
            
            Text(course.description ?? "")
                .font(.body)
            
            Text("Course Content")
                .font(.headline)
                .padding(.top)
            
            Text("This is where you would display additional course content, such as reading materials and interactive exercises.")
                .font(.body)
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(Color.pantheleumText)
        .onAppear {
            loadVideo()
        }
        .onDisappear {
            player?.pause()
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            if let player = player {
                FullScreenVideoPlayer(player: player)
            }
        }
    }
    
    private func loadVideo() {
        guard let url = URL(string: course.videoURL) else {
            print("Invalid video URL")
            return
        }
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Enable audio playback when device is silent
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
}

struct CourseListView: View {
    @Binding var isLoggedIn: Bool
    @State private var courses: [Course] = []
    
    var body: some View {
        NavigationView {
            List(courses) { course in
                NavigationLink(destination: CourseDetailView(course: course)) {
                    VStack(alignment: .leading) {
                        Text(course.title)
                            .font(.headline)
                        if let description = course.description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("My Courses")
            .navigationBarItems(trailing: Button(action: logOut) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
            })
            .onAppear(perform: loadAssignedCourses)
        }
    }
    
    func loadAssignedCourses() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserManager.shared.getUser(uid: uid) { result in
            switch result {
            case .success(let user):
                if user.isAdmin {
                    self.loadAllCourses()
                } else {
                    self.loadUserCourses(uid: uid)
                }
            case .failure(let error):
                print("Error getting user: \(error)")
            }
        }
    }
    
    func loadAllCourses() {
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
    
    func loadUserCourses(uid: String) {
        let db = Firestore.firestore()
        db.collection("courses")
            .whereField("assignedUsers", arrayContains: uid)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.courses = querySnapshot?.documents.compactMap { document in
                        Course(document: document)
                    } ?? []
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
    
    func checkAdminStatus() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Debug: No authenticated user found")
            return
        }
        UserManager.shared.getUser(uid: uid) { result in
            switch result {
            case .success(let user):
                print("Debug: Current user isAdmin: \(user.isAdmin)")
            case .failure(let error):
                print("Debug: Error fetching user: \(error.localizedDescription)")
            }
        }
    }
}