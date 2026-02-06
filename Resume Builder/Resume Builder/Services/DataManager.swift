import Foundation
import Combine

@MainActor
class DataManager: ObservableObject {
    @Published var resume: Resume
    @Published var applications: [JobApplication]
    
    private let resumeKey = "saved_resume"
    private let applicationsKey = "saved_applications"
    
    init() {
        // Load saved resume
        if let data = UserDefaults.standard.data(forKey: resumeKey),
           let saved = try? JSONDecoder().decode(Resume.self, from: data) {
            self.resume = saved
            print("✅ Loaded resume: \(saved.personalInfo.fullName)")
        } else {
            self.resume = Resume()
            print("⚠️ No saved resume found, creating new")
        }
        
        // Load saved applications
        if let data = UserDefaults.standard.data(forKey: applicationsKey),
           let saved = try? JSONDecoder().decode([JobApplication].self, from: data) {
            self.applications = saved
        } else {
            self.applications = []
        }
    }
    
    func saveResume() {
        resume.updatedAt = Date()
        if let data = try? JSONEncoder().encode(resume) {
            UserDefaults.standard.set(data, forKey: resumeKey)
            UserDefaults.standard.synchronize()
            print("✅ Resume saved: \(resume.personalInfo.fullName)")
        }
    }
    
    func saveApplications() {
        if let data = try? JSONEncoder().encode(applications) {
            UserDefaults.standard.set(data, forKey: applicationsKey)
        }
    }
    
    func addApplication(_ application: JobApplication) {
        applications.insert(application, at: 0)
        saveApplications()
    }
    
    func updateApplication(_ application: JobApplication) {
        if let index = applications.firstIndex(where: { $0.id == application.id }) {
            applications[index] = application
            saveApplications()
        }
    }
    
    func deleteApplication(_ application: JobApplication) {
        applications.removeAll { $0.id == application.id }
        saveApplications()
    }
    
    // MARK: - Statistics
    
    var activeApplicationsCount: Int {
        applications.filter { 
            ![.rejected, .withdrawn, .accepted].contains($0.status)
        }.count
    }
    
    var interviewsCount: Int {
        applications.filter {
            [.phoneScreen, .interview, .technicalInterview, .finalInterview].contains($0.status)
        }.count
    }
    
    var offersCount: Int {
        applications.filter { $0.status == .offer || $0.status == .accepted }.count
    }
    
    var applicationsByStatus: [ApplicationStatus: Int] {
        Dictionary(grouping: applications, by: { $0.status })
            .mapValues { $0.count }
    }
}
