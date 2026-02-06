import SwiftUI

@main
struct ResumeBuilderApp: App {
    @StateObject private var authManager = GitHubAuthManager()
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(dataManager)
        }
    }
}
