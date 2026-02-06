import Foundation

struct GitHubUser: Codable {
    let id: Int
    let login: String
    let name: String?
    let email: String?
    let avatarUrl: String?
    let bio: String?
    let location: String?
    let blog: String?
    let twitterUsername: String?
    let publicRepos: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, login, name, email, bio, location, blog
        case avatarUrl = "avatar_url"
        case twitterUsername = "twitter_username"
        case publicRepos = "public_repos"
    }
}

struct GitHubRepo: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let htmlUrl: String
    let language: String?
    let stargazersCount: Int
    let fork: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, language, fork
        case htmlUrl = "html_url"
        case stargazersCount = "stargazers_count"
    }
}
