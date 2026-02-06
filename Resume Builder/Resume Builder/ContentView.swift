import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: GitHubAuthManager
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                TabView(selection: $selectedTab) {
                    ResumeEditorView()
                        .tabItem {
                            Label("Resume", systemImage: "doc.text.fill")
                        }
                        .tag(0)
                    
                    TemplateGalleryView()
                        .tabItem {
                            Label("Templates", systemImage: "square.grid.2x2.fill")
                        }
                        .tag(1)
                    
                    PublishView()
                        .tabItem {
                            Label("Publish", systemImage: "globe")
                        }
                        .tag(2)
                    
                    JobTrackerView()
                        .tabItem {
                            Label("Tracker", systemImage: "chart.bar.fill")
                        }
                        .tag(3)
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(4)
                }
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut, value: authManager.isAuthenticated)
    }
}

#Preview {
    ContentView()
        .environmentObject(GitHubAuthManager())
        .environmentObject(DataManager())
}
