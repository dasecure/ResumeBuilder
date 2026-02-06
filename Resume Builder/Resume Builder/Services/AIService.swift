import Foundation

class AIService {
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    private var apiKey: String {
        UserDefaults.standard.string(forKey: "ai_api_key") ?? ""
    }
    
    private var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: "ai_enabled")
    }
    
    enum AIError: Error, LocalizedError {
        case invalidResponse
        case apiError(String)
        case noApiKey
        case disabled
        
        var errorDescription: String? {
            switch self {
            case .invalidResponse: return "Invalid response from AI"
            case .apiError(let msg): return msg
            case .noApiKey: return "Please add your OpenAI API key in Settings → AI Settings"
            case .disabled: return "AI features are disabled"
            }
        }
    }
    
    // MARK: - Resume Enhancement
    
    func enhanceJobDescription(title: String, company: String, description: String) async throws -> String {
        let prompt = """
        Improve this job description for a resume. Make it more impactful with action verbs and quantifiable achievements where possible. Keep it concise (3-4 bullet points).
        
        Job Title: \(title)
        Company: \(company)
        Current Description: \(description)
        
        Return only the improved bullet points, one per line starting with •
        """
        
        return try await sendRequest(prompt: prompt)
    }
    
    func generateSummary(resume: Resume) async throws -> String {
        let experienceText = resume.experiences.map { "\($0.title) at \($0.company)" }.joined(separator: ", ")
        let skillsText = resume.skills.joined(separator: ", ")
        
        let prompt = """
        Write a professional summary (2-3 sentences) for a resume with:
        - Name: \(resume.personalInfo.fullName)
        - Experience: \(experienceText)
        - Skills: \(skillsText)
        
        Make it compelling and tailored for job applications. Return only the summary text.
        """
        
        return try await sendRequest(prompt: prompt)
    }
    
    func suggestSkills(for title: String, existingSkills: [String]) async throws -> [String] {
        let prompt = """
        Suggest 5 relevant skills for someone with the job title "\(title)" that they might be missing.
        
        They already have: \(existingSkills.joined(separator: ", "))
        
        Return only the skill names, one per line, no numbers or bullets.
        """
        
        let response = try await sendRequest(prompt: prompt)
        return response.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    func improveHighlight(_ text: String, context: String) async throws -> String {
        let prompt = """
        Improve this resume bullet point to be more impactful. Use strong action verbs and include metrics/results if possible.
        
        Context: \(context)
        Original: \(text)
        
        Return only the improved bullet point.
        """
        
        return try await sendRequest(prompt: prompt)
    }
    
    // MARK: - Private
    
    private func sendRequest(prompt: String) async throws -> String {
        guard isEnabled else {
            throw AIError.disabled
        }
        
        guard !apiKey.isEmpty else {
            throw AIError.noApiKey
        }
        
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a professional resume writer. Be concise and impactful."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 500,
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
