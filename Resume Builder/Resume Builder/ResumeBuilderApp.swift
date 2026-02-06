import SwiftUI

@main
struct ResumeBuilderApp: App {
    @StateObject private var authManager = GitHubAuthManager()
    @StateObject private var dataManager = DataManager()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(dataManager)
                .onChange(of: scenePhase) {
                    if scenePhase == .background || scenePhase == .inactive {
                        dataManager.saveResume()
                        dataManager.saveApplications()
                    }
                }
        }
    }
}
