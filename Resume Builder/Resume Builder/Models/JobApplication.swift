import Foundation

struct JobApplication: Codable, Identifiable, Equatable {
    var id = UUID()
    var company: String
    var position: String
    var jobURL: String?
    var status: ApplicationStatus
    var appliedDate: Date
    var lastUpdated: Date
    var notes: String
    var contactName: String?
    var contactEmail: String?
    var salary: String?
    var location: String?
    var isRemote: Bool
    var events: [ApplicationEvent]
    
    init(company: String = "", position: String = "") {
        self.company = company
        self.position = position
        self.status = .applied
        self.appliedDate = Date()
        self.lastUpdated = Date()
        self.notes = ""
        self.isRemote = false
        self.events = [
            ApplicationEvent(type: .applied, date: Date())
        ]
    }
    
    mutating func updateStatus(_ newStatus: ApplicationStatus) {
        self.status = newStatus
        self.lastUpdated = Date()
        self.events.append(ApplicationEvent(type: eventType(for: newStatus), date: Date()))
    }
    
    private func eventType(for status: ApplicationStatus) -> EventType {
        switch status {
        case .applied: return .applied
        case .reviewing: return .statusChange
        case .phoneScreen: return .phoneScreen
        case .interview: return .interview
        case .technicalInterview: return .technicalInterview
        case .finalInterview: return .finalInterview
        case .offer: return .offer
        case .accepted: return .accepted
        case .rejected: return .rejected
        case .withdrawn: return .withdrawn
        }
    }
}

enum ApplicationStatus: String, Codable, CaseIterable, Equatable {
    case applied = "Applied"
    case reviewing = "Under Review"
    case phoneScreen = "Phone Screen"
    case interview = "Interview"
    case technicalInterview = "Technical Interview"
    case finalInterview = "Final Interview"
    case offer = "Offer Received"
    case accepted = "Accepted"
    case rejected = "Rejected"
    case withdrawn = "Withdrawn"
    
    var color: String {
        switch self {
        case .applied: return "blue"
        case .reviewing: return "orange"
        case .phoneScreen, .interview, .technicalInterview, .finalInterview: return "purple"
        case .offer: return "green"
        case .accepted: return "green"
        case .rejected: return "red"
        case .withdrawn: return "gray"
        }
    }
    
    var icon: String {
        switch self {
        case .applied: return "paperplane.fill"
        case .reviewing: return "eye.fill"
        case .phoneScreen: return "phone.fill"
        case .interview, .technicalInterview, .finalInterview: return "person.2.fill"
        case .offer: return "gift.fill"
        case .accepted: return "checkmark.seal.fill"
        case .rejected: return "xmark.circle.fill"
        case .withdrawn: return "arrow.uturn.backward"
        }
    }
}

struct ApplicationEvent: Codable, Identifiable, Equatable {
    var id = UUID()
    var type: EventType
    var date: Date
    var notes: String?
}

enum EventType: String, Codable, Equatable {
    case applied = "Applied"
    case statusChange = "Status Updated"
    case phoneScreen = "Phone Screen"
    case interview = "Interview"
    case technicalInterview = "Technical Interview"
    case finalInterview = "Final Interview"
    case offer = "Offer Received"
    case accepted = "Accepted"
    case rejected = "Rejected"
    case withdrawn = "Withdrawn"
    case note = "Note Added"
    case followUp = "Follow Up"
}
