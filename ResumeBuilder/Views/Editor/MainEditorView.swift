import SwiftUI

struct MainEditorView: View {
    @EnvironmentObject var authManager: GitHubAuthManager
    @StateObject private var viewModel = EditorViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Section", selection: $selectedTab) {
                    Text("Profile").tag(0)
                    Text("Projects").tag(1)
                    Text("Theme").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                TabView(selection: $selectedTab) {
                    ProfileEditorView(portfolio: $viewModel.portfolio)
                        .tag(0)
                    
                    ProjectsEditorView(projects: $viewModel.portfolio.projects)
                        .tag(1)
                    
                    ThemePickerView(selectedTheme: $viewModel.portfolio.theme)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("ResumeBuilder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button(role: .destructive, action: { authManager.signOut() }) {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        if let avatarUrl = authManager.user?.avatarUrl,
                           let url = URL(string: avatarUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { viewModel.publish() }) {
                        if viewModel.isPublishing {
                            ProgressView()
                        } else {
                            Label("Publish", systemImage: "paperplane.fill")
                        }
                    }
                    .disabled(viewModel.isPublishing)
                }
            }
            .alert("Published! 🎉", isPresented: $viewModel.showSuccess) {
                Button("Open Site") {
                    if let url = URL(string: viewModel.publishedURL) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your portfolio is live at:\n\(viewModel.publishedURL)")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .onAppear {
            if let user = authManager.user {
                viewModel.setup(user: user, token: authManager.getAccessToken() ?? "")
            }
        }
    }
}

#Preview {
    MainEditorView()
        .environmentObject(GitHubAuthManager())
}
