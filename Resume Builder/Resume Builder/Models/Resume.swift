import Foundation



struct Resume: Codable, Identifiable, Equatable {
    var id = UUID()
    var personalInfo: PersonalInfo
    var summary: String
    var experiences: [Experience]
    var education: [Education]
    var skills: [String]
    var languages: [Language]
    var achievements: [String]
    var patents: [Patent]
    var hobbies: [String]
    var template: ResumeTemplate
    var templateSettings: TemplateSettings
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
        self.languages = []
        self.achievements = []
        self.patents = []
        self.hobbies = []
        self.template = .professional
        self.templateSettings = TemplateSettings()
        self.isPublished = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct Language: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var proficiency: LanguageProficiency
    
    init(name: String = "", proficiency: LanguageProficiency = .conversational) {
        self.name = name
        self.proficiency = proficiency
    }
}

enum LanguageProficiency: String, Codable, CaseIterable, Equatable {
    case native = "Native"
    case fluent = "Fluent"
    case conversational = "Conversational"
    case basic = "Basic"
}

struct Patent: Codable, Identifiable, Equatable {
    var id = UUID()
    var title: String
    var patentNumber: String
    var dateIssued: Date?
    var status: PatentStatus
    
    init(title: String = "", patentNumber: String = "", status: PatentStatus = .pending) {
        self.title = title
        self.patentNumber = patentNumber
        self.status = status
    }
}

enum PatentStatus: String, Codable, CaseIterable, Equatable {
    case pending = "Pending"
    case granted = "Granted"
    case provisional = "Provisional"
}

struct PersonalInfo: Codable, Equatable {
    var fullName: String = ""
    var email: String = ""
    var phone: String = ""
    var location: String = ""
    var linkedIn: String = ""
    var website: String = ""
    var githubUsername: String = ""
    var avatarURL: String?
}

struct Experience: Codable, Identifiable, Equatable {
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

struct Education: Codable, Identifiable, Equatable {
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
    
    var defaultColors: TemplateColors {
        switch self {
        case .professional: return TemplateColors(primary: "#0066cc", secondary: "#1a1a2e", accent: "#0066cc", background: "#ffffff")
        case .casual: return TemplateColors(primary: "#00b894", secondary: "#2d3436", accent: "#00b894", background: "#f8f9fa")
        case .playful: return TemplateColors(primary: "#6c5ce7", secondary: "#ffffff", accent: "#fd79a8", background: "#6c5ce7")
        }
    }
}

struct TemplateColors: Codable, Equatable {
    var primary: String      // Main accent color (links, headers)
    var secondary: String    // Text color
    var accent: String       // Highlights, buttons
    var background: String   // Page background
    
    static let presets: [(name: String, colors: TemplateColors)] = [
        ("Ocean Blue", TemplateColors(primary: "#0066cc", secondary: "#1a1a2e", accent: "#0066cc", background: "#ffffff")),
        ("Forest Green", TemplateColors(primary: "#00b894", secondary: "#2d3436", accent: "#00b894", background: "#ffffff")),
        ("Royal Purple", TemplateColors(primary: "#6c5ce7", secondary: "#2d3436", accent: "#6c5ce7", background: "#ffffff")),
        ("Sunset Orange", TemplateColors(primary: "#e17055", secondary: "#2d3436", accent: "#e17055", background: "#ffffff")),
        ("Rose Pink", TemplateColors(primary: "#fd79a8", secondary: "#2d3436", accent: "#fd79a8", background: "#ffffff")),
        ("Midnight", TemplateColors(primary: "#74b9ff", secondary: "#dfe6e9", accent: "#74b9ff", background: "#2d3436")),
        ("Coral", TemplateColors(primary: "#ff7675", secondary: "#2d3436", accent: "#ff7675", background: "#fff5f5")),
        ("Teal", TemplateColors(primary: "#00cec9", secondary: "#2d3436", accent: "#00cec9", background: "#ffffff")),
    ]
}

struct TemplateSettings: Codable, Equatable {
    var professionalColors: TemplateColors
    var casualColors: TemplateColors
    var playfulColors: TemplateColors
    
    init() {
        self.professionalColors = ResumeTemplate.professional.defaultColors
        self.casualColors = ResumeTemplate.casual.defaultColors
        self.playfulColors = ResumeTemplate.playful.defaultColors
    }
    
    func colors(for template: ResumeTemplate) -> TemplateColors {
        switch template {
        case .professional: return professionalColors
        case .casual: return casualColors
        case .playful: return playfulColors
        }
    }
    
    mutating func setColors(_ colors: TemplateColors, for template: ResumeTemplate) {
        switch template {
        case .professional: professionalColors = colors
        case .casual: casualColors = colors
        case .playful: playfulColors = colors
        }
    }
}
