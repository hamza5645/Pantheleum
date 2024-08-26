import FirebaseFirestore

struct Course: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let description: String
    let videoURL: String
    var assignedUsers: [String]
}

extension Course {
    var dictionary: [String: Any] {
        return [
            "title": title,
            "description": description,
            "videoURL": videoURL,
            "assignedUsers": assignedUsers
        ]
    }
}