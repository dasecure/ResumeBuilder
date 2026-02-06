import Foundation
import AuthenticationServices

@MainActor
class GitHubAuthManager: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var user: GitHubUser?
    @Published var error: String?
    
    private var accessToken: String? {
        didSet {
            if let token = accessToken {
                KeychainHelper.save(token, forKey: "github_access_token")
                isAuthenticated = true
            } else {
                KeychainHelper.delete(forKey: "github_access_token")
                isAuthenticated = false
            }
        }
    }
    
    // GitHub OAuth App credentials
    private let clientId = "Ov23liPPvIDepbvyOZwg"
    private let clientSecret = "7472ca4e3878aaf71aa8ec8439e3c9c6c2c170f5"
    private let redirectURI = "resumebuilder://callback"
    private let scope = "repo,user"
    
    override init() {
        super.init()
        // Check for existing token
        if let token = KeychainHelper.load(forKey: "github_access_token") {
            self.accessToken = token
            self.isAuthenticated = true
            Task { await fetchUser() }
        }
    }
    
    func signIn() {
        isLoading = true
        error = nil
        
        let authURL = URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientId)&redirect_uri=\(redirectURI)&scope=\(scope)")!
        
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "resumebuilder") { [weak self] callbackURL, error in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                
                guard let callbackURL = callbackURL,
                      let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                        .queryItems?.first(where: { $0.name == "code" })?.value else {
                    self.error = "Failed to get authorization code"
                    return
                }
                
                await self.exchangeCodeForToken(code: code)
            }
        }
        
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = false
        session.start()
    }
    
    private func exchangeCodeForToken(code: String) async {
        let url = URL(string: "https://github.com/login/oauth/access_token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body: [String: String] = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": code,
            "redirect_uri": redirectURI
        ]
        
        request.httpBody = try? JSONEncoder().encode(body)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(TokenResponse.self, from: data)
            self.accessToken = response.accessToken
            await fetchUser()
        } catch {
            self.error = "Failed to get access token: \(error.localizedDescription)"
        }
    }
    
    func fetchUser() async {
        guard let token = accessToken else { return }
        
        let url = URL(string: "https://api.github.com/user")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            self.user = try JSONDecoder().decode(GitHubUser.self, from: data)
        } catch {
            self.error = "Failed to fetch user: \(error.localizedDescription)"
        }
    }
    
    func signOut() {
        accessToken = nil
        user = nil
        isAuthenticated = false
    }
    
    func getAccessToken() -> String? {
        return accessToken
    }
}

extension GitHubAuthManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

private struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
    }
}
