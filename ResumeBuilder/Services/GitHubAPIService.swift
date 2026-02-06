import Foundation

class GitHubAPIService {
    private let baseURL = "https://api.github.com"
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    private func makeRequest(url: URL, method: String = "GET", body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        return request
    }
    
    // MARK: - Repository Operations
    
    func checkRepoExists(username: String, repoName: String) async throws -> Bool {
        let url = URL(string: "\(baseURL)/repos/\(username)/\(repoName)")!
        let request = makeRequest(url: url)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { return false }
        return httpResponse.statusCode == 200
    }
    
    func createRepo(name: String, description: String = "My portfolio site") async throws -> GitHubRepo {
        let url = URL(string: "\(baseURL)/user/repos")!
        
        let body: [String: Any] = [
            "name": name,
            "description": description,
            "homepage": "https://\(name)",
            "private": false,
            "has_issues": false,
            "has_projects": false,
            "has_wiki": false,
            "auto_init": true
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        let request = makeRequest(url: url, method: "POST", body: jsonData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(GitHubRepo.self, from: data)
    }
    
    func enableGitHubPages(username: String, repoName: String) async throws {
        let url = URL(string: "\(baseURL)/repos/\(username)/\(repoName)/pages")!
        
        let body: [String: Any] = [
            "source": [
                "branch": "main",
                "path": "/"
            ]
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        let request = makeRequest(url: url, method: "POST", body: jsonData)
        
        let _ = try await URLSession.shared.data(for: request)
    }
    
    // MARK: - File Operations
    
    func getFileSHA(username: String, repoName: String, path: String) async throws -> String? {
        let url = URL(string: "\(baseURL)/repos/\(username)/\(repoName)/contents/\(path)")!
        let request = makeRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return nil
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return json?["sha"] as? String
    }
    
    func commitFile(username: String, repoName: String, path: String, content: String, message: String) async throws {
        let url = URL(string: "\(baseURL)/repos/\(username)/\(repoName)/contents/\(path)")!
        
        let base64Content = Data(content.utf8).base64EncodedString()
        
        var body: [String: Any] = [
            "message": message,
            "content": base64Content
        ]
        
        // Check if file exists to get SHA for update
        if let sha = try await getFileSHA(username: username, repoName: repoName, path: path) {
            body["sha"] = sha
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        let request = makeRequest(url: url, method: "PUT", body: jsonData)
        
        let _ = try await URLSession.shared.data(for: request)
    }
    
    // MARK: - Fetch User's Repos
    
    func fetchUserRepos() async throws -> [GitHubRepo] {
        let url = URL(string: "\(baseURL)/user/repos?sort=updated&per_page=100")!
        let request = makeRequest(url: url)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([GitHubRepo].self, from: data)
    }
    
    // MARK: - Deploy Portfolio
    
    func deployPortfolio(username: String, portfolio: Portfolio, htmlContent: String) async throws -> String {
        let repoName = "\(username).github.io"
        
        // Check if repo exists
        let exists = try await checkRepoExists(username: username, repoName: repoName)
        
        if !exists {
            // Create the repository
            let _ = try await createRepo(name: repoName, description: portfolio.bio)
            // Wait a moment for repo to be ready
            try await Task.sleep(nanoseconds: 2_000_000_000)
        }
        
        // Commit the index.html
        try await commitFile(
            username: username,
            repoName: repoName,
            path: "index.html",
            content: htmlContent,
            message: "Update portfolio via ResumeBuilder"
        )
        
        // Enable GitHub Pages if needed
        try? await enableGitHubPages(username: username, repoName: repoName)
        
        return "https://\(username).github.io"
    }
}
