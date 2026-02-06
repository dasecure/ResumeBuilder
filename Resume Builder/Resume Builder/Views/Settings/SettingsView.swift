import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: GitHubAuthManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            List {
                // Account Section
                Section("Account") {
                    if let user = authManager.user {
                        HStack(spacing: 12) {
                            if let avatarUrl = user.avatarUrl,
                               let url = URL(string: avatarUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    Circle().fill(Color.gray.opacity(0.3))
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            }
                            
                            VStack(alignment: .leading) {
                                Text(user.name ?? user.login)
                                    .font(.headline)
                                Text("@\(user.login)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(action: { authManager.signOut() }) {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
                
                // Resume Section
                Section("Resume") {
                    NavigationLink(destination: TemplateColorsView()) {
                        Label("Template Colors", systemImage: "paintpalette.fill")
                    }
                    
                    NavigationLink(destination: ExportOptionsView()) {
                        Label("Export Resume", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: { showingDeleteConfirmation = true }) {
                        Label("Delete Resume Data", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                // AI Section
                Section {
                    NavigationLink(destination: AISettingsView()) {
                        Label("AI Settings", systemImage: "sparkles")
                    }
                } header: {
                    Text("AI Assistant")
                } footer: {
                    Text("Configure AI-powered resume enhancement features")
                }
                
                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://dasecure.com")!) {
                        Label("DaSecure Solutions", systemImage: "link")
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    
                    NavigationLink(destination: TermsOfServiceView()) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }
                
                // Support Section
                Section("Support") {
                    Link(destination: URL(string: "mailto:support@dasecure.com")!) {
                        Label("Contact Support", systemImage: "envelope")
                    }
                    
                    Link(destination: URL(string: "https://twitter.com/dasecure")!) {
                        Label("Follow on Twitter", systemImage: "at")
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Delete Resume Data?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    dataManager.resume = Resume()
                    dataManager.saveResume()
                }
            } message: {
                Text("This will permanently delete all your resume data. This action cannot be undone.")
            }
        }
    }
}

struct TemplateColorsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTemplate: ResumeTemplate = .professional
    
    var body: some View {
        List {
            // Template Picker
            Section {
                Picker("Template", selection: $selectedTemplate) {
                    ForEach(ResumeTemplate.allCases, id: \.self) { template in
                        Text(template.rawValue).tag(template)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Color Presets
            Section("Color Presets") {
                ForEach(TemplateColors.presets, id: \.name) { preset in
                    Button {
                        dataManager.resume.templateSettings.setColors(preset.colors, for: selectedTemplate)
                        dataManager.saveResume()
                    } label: {
                        HStack(spacing: 12) {
                            // Color preview circles
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color(hex: preset.colors.primary))
                                    .frame(width: 24, height: 24)
                                Circle()
                                    .fill(Color(hex: preset.colors.accent))
                                    .frame(width: 24, height: 24)
                                Circle()
                                    .fill(Color(hex: preset.colors.background))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            
                            Text(preset.name)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if dataManager.resume.templateSettings.colors(for: selectedTemplate) == preset.colors {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
            
            // Current Colors
            Section("Current Colors") {
                ColorRow(
                    title: "Primary",
                    color: dataManager.resume.templateSettings.colors(for: selectedTemplate).primary,
                    systemImage: "paintbrush.fill"
                )
                ColorRow(
                    title: "Accent",
                    color: dataManager.resume.templateSettings.colors(for: selectedTemplate).accent,
                    systemImage: "star.fill"
                )
                ColorRow(
                    title: "Background",
                    color: dataManager.resume.templateSettings.colors(for: selectedTemplate).background,
                    systemImage: "rectangle.fill"
                )
            }
            
            // Reset
            Section {
                Button(action: resetToDefault) {
                    Label("Reset to Default", systemImage: "arrow.counterclockwise")
                }
            }
        }
        .navigationTitle("Template Colors")
    }
    
    private func resetToDefault() {
        dataManager.resume.templateSettings.setColors(selectedTemplate.defaultColors, for: selectedTemplate)
        dataManager.saveResume()
    }
}

struct ColorRow: View {
    let title: String
    let color: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(Color(hex: color))
            Text(title)
            Spacer()
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: color))
                .frame(width: 60, height: 28)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            Text(color.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospaced()
        }
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ExportOptionsView: View {
    var body: some View {
        List {
            Section("Export Format") {
                Button(action: exportAsPDF) {
                    Label("Export as PDF", systemImage: "doc.fill")
                }
                
                Button(action: exportAsHTML) {
                    Label("Export as HTML", systemImage: "chevron.left.forwardslash.chevron.right")
                }
                
                Button(action: exportAsJSON) {
                    Label("Export as JSON", systemImage: "curlybraces")
                }
            }
        }
        .navigationTitle("Export Resume")
    }
    
    private func exportAsPDF() {
        // TODO: Implement PDF export
    }
    
    private func exportAsHTML() {
        // TODO: Implement HTML export
    }
    
    private func exportAsJSON() {
        // TODO: Implement JSON export
    }
}

struct AISettingsView: View {
    @AppStorage("ai_api_key") private var apiKey = ""
    @AppStorage("ai_enabled") private var aiEnabled = true
    
    var body: some View {
        Form {
            Section {
                Toggle("Enable AI Features", isOn: $aiEnabled)
            } footer: {
                Text("AI helps improve your resume content with better wording and suggestions.")
            }
            
            Section {
                SecureField("sk-...", text: $apiKey)
                    .textContentType(.password)
                    .autocapitalization(.none)
            } header: {
                Text("OpenAI API Key")
            } footer: {
                Text("Optional: Add your own OpenAI API key for unlimited AI features. Get one at platform.openai.com")
            }
        }
        .navigationTitle("AI Settings")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("""
            Privacy Policy
            
            Last updated: February 2026
            
            ResumeBuilder ("we", "our", or "us") respects your privacy and is committed to protecting your personal data.
            
            Data We Collect:
            • GitHub account information (username, email, avatar)
            • Resume content you create
            • Job application tracking data
            
            How We Use Your Data:
            • To create and publish your resume
            • To track your job applications
            • To improve our services
            
            Data Storage:
            • Resume data is stored locally on your device
            • Published resumes are hosted on GitHub Pages
            
            Third-Party Services:
            • GitHub (authentication and hosting)
            • OpenAI (optional AI features)
            
            Your Rights:
            • Access your data anytime
            • Delete your data through the app
            • Export your resume
            
            Contact:
            privacy@dasecure.com
            """)
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            Text("""
            Terms of Service
            
            Last updated: February 2026
            
            By using ResumeBuilder, you agree to these terms.
            
            Use of Service:
            • You must be 13 years or older
            • You are responsible for your account
            • Don't use the service for illegal purposes
            
            Your Content:
            • You own your resume content
            • You grant us permission to host it
            • Don't include false information
            
            GitHub Integration:
            • Requires a GitHub account
            • Subject to GitHub's terms
            
            AI Features:
            • AI suggestions are not guaranteed
            • Review all AI-generated content
            
            Limitation of Liability:
            • Service provided "as is"
            • We're not liable for damages
            
            Changes:
            • We may update these terms
            • Continued use means acceptance
            
            Contact:
            legal@dasecure.com
            """)
            .padding()
        }
        .navigationTitle("Terms of Service")
    }
}

#Preview {
    SettingsView()
        .environmentObject(GitHubAuthManager())
        .environmentObject(DataManager())
}
