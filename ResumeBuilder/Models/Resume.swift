import Foundation

struct Resume: Codable, Identifiable {
    var id = UUID()
    var personalInfo: PersonalInfo
    var summary: String
    var experiences: [Experience]
    var education: [Education]
    var skills: [String]
    var template: ResumeTemplate
    var isPublished: Bool
    var publishedURL: String?
    var customDomain: String?
    var createdAt: Date
    var updatedAt: Date
    
    init() {
        self.personalInfo = PersonalInfo()
        self.summary = ""
        self.experiences = []
        self.education = []
        self.skills = []
        self.template = .professional
        self.isPublished = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct PersonalInfo: Codable {
    var fullName: String = ""
    var email: String = ""
    var phone: String = ""
    var location: String = ""
    var linkedIn: String = ""
    var website: String = ""
    var githubUsername: String = ""
    var avatarURL: String?
}

struct Experience: Codable, Identifiable {
    var id = UUID()
    var company: String
    var title: String
    var location: String
    var startDate: Date
    var endDate: Date?
    var isCurrentRole: Bool
    var description: String
    var highlights: [String]
    
    init() {
        self.company = ""
        self.title = ""
        self.location = ""
        self.startDate = Date()
        self.isCurrentRole = false
        self.description = ""
        self.highlights = []
    }
}

struct Education: Codable, Identifiable {
    var id = UUID()
    var institution: String
    var degree: String
    var field: String
    var graduationDate: Date?
    var gpa: String?
    var highlights: [String]
    
    init() {
        self.institution = ""
        self.degree = ""
        self.field = ""
        self.highlights = []
    }
}

enum ResumeTemplate: String, Codable, CaseIterable {
    case professional = "Professional"
    case casual = "Casual"
    case playful = "Playful"
    
    var description: String {
        switch self {
        case .professional: return "Clean, corporate look for traditional industries"
        case .casual: return "Friendly, modern design for startups & tech"
        case .playful: return "Creative, bold style for design & creative roles"
        }
    }
    
    var colors: (primary: String, secondary: String, accent: String) {
        switch self {
        case .professional: return ("#1a1a2e", "#f5f5f5", "#0066cc")
        case .casual: return ("#2d3436", "#ffffff", "#00b894")
        case .playful: return ("#6c5ce7", "#ffeaa7", "#fd79a8")
        }
    }
}
