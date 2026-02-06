import Foundation

struct Portfolio: Codable, Identifiable {
    var id = UUID()
    var name: String
    var bio: String
    var avatarURL: String?
    var email: String?
    var location: String?
    var website: String?
    var githubUsername: String
    var linkedIn: String?
    var twitter: String?
    var projects: [Project]
    var skills: [String]
    var theme: Theme
    
    init(githubUsername: String) {
        self.name = ""
        self.bio = ""
        self.githubUsername = githubUsername
        self.projects = []
        self.skills = []
        self.theme = .minimal
    }
}

struct Project: Codable, Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var url: String?
    var repoURL: String?
    var technologies: [String]
    var featured: Bool
    
    init(name: String = "", description: String = "") {
        self.name = name
        self.description = description
        self.technologies = []
        self.featured = false
    }
}

enum Theme: String, Codable, CaseIterable {
    case minimal = "Minimal"
    case modern = "Modern"
    case developer = "Developer"
    
    var previewImage: String {
        switch self {
        case .minimal: return "template_minimal"
        case .modern: return "template_modern"
        case .developer: return "template_developer"
        }
    }
}
