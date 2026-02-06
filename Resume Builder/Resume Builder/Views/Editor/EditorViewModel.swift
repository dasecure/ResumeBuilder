import Foundation

@MainActor
class EditorViewModel: ObservableObject {
    @Published var portfolio = Portfolio(githubUsername: "")
    @Published var isPublishing = false
    @Published var showSuccess = false
    @Published var showError = false
    @Published var publishedURL = ""
    @Published var errorMessage = ""
    
    private var apiService: GitHubAPIService?
    
    func setup(user: GitHubUser, token: String) {
        portfolio.githubUsername = user.login
        portfolio.name = user.name ?? user.login
        portfolio.bio = user.bio ?? ""
        portfolio.email = user.email
        portfolio.location = user.location
        portfolio.website = user.blog
        portfolio.avatarURL = user.avatarUrl
        portfolio.twitter = user.twitterUsername
        
        apiService = GitHubAPIService(accessToken: token)
        
        Task {
            await loadUserRepos()
        }
    }
    
    private func loadUserRepos() async {
        guard let service = apiService else { return }
        
        do {
            let repos = try await service.fetchUserRepos()
            let projects = repos
                .filter { !$0.fork }
                .prefix(6)
                .map { repo in
                    var project = Project(name: repo.name, description: repo.description ?? "")
                    project.repoURL = repo.htmlUrl
                    if let lang = repo.language {
                        project.technologies = [lang]
                    }
                    return project
                }
            
            portfolio.projects = Array(projects)
        } catch {
            print("Failed to load repos: \(error)")
        }
    }
    
    func publish() {
        guard let service = apiService else {
            errorMessage = "Not authenticated"
            showError = true
            return
        }
        
        isPublishing = true
        
        Task {
            do {
                let html = TemplateGenerator.generate(portfolio: portfolio)
                let url = try await service.deployPortfolio(
                    username: portfolio.githubUsername,
                    portfolio: portfolio,
                    htmlContent: html
                )
                publishedURL = url
                showSuccess = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isPublishing = false
        }
    }
}
