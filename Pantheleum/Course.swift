import FirebaseFirestore

struct Course: Identifiable, Codable {
    var id: String
    let title: String
    let description: String?
    let videoURL: String
    var assignedUsers: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case videoURL
        case assignedUsers
    }
    
    init(id: String = UUID().uuidString, title: String, description: String?, videoURL: String, assignedUsers: [String]) {
        self.id = id
        self.title = title
        self.description = description
        self.videoURL = videoURL
        self.assignedUsers = assignedUsers
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let id = data["id"] as? String,
              let title = data["title"] as? String,
              let videoURL = data["videoURL"] as? String,
              let assignedUsers = data["assignedUsers"] as? [String] else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.description = data["description"] as? String
        self.videoURL = videoURL
        self.assignedUsers = assignedUsers
    }
    
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "title": title,
            "videoURL": videoURL,
            "assignedUsers": assignedUsers
        ]
        if let description = description {
            dict["description"] = description
        }
        return dict
    }
}