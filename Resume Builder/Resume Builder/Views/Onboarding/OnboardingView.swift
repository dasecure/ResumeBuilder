import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authManager: GitHubAuthManager
    @State private var currentPage = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Page Indicator
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 20)
            
            // Onboarding Pages
            TabView(selection: $currentPage) {
                WelcomePage()
                    .tag(0)
                
                FeaturesPage()
                    .tag(1)
                
                SignInPage()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color(.systemBackground))
    }
}

struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Illustration
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
            }
            
            // Text
            VStack(spacing: 16) {
                Text("ResumeBuilder")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                
                Text("Create a stunning resume and publish it\nto the web in minutes")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

struct FeaturesPage: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("Everything You Need")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 24) {
                FeatureRow(
                    icon: "sparkles",
                    color: .purple,
                    title: "AI-Powered Writing",
                    subtitle: "Get help crafting the perfect descriptions"
                )
                
                FeatureRow(
                    icon: "paintpalette.fill",
                    color: .pink,
                    title: "Beautiful Templates",
                    subtitle: "Professional, Casual, or Playful styles"
                )
                
                FeatureRow(
                    icon: "globe",
                    color: .blue,
                    title: "Instant Publishing",
                    subtitle: "Go live on the web with one tap"
                )
                
                FeatureRow(
                    icon: "chart.bar.fill",
                    color: .green,
                    title: "Job Tracker",
                    subtitle: "Track applications and interviews"
                )
            }
            .padding(.horizontal, 32)
            
            Spacer()
            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct SignInPage: View {
    @EnvironmentObject var authManager: GitHubAuthManager
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // GitHub Logo
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 50, weight: .medium))
            }
            
            // Text
            VStack(spacing: 12) {
                Text("Connect with GitHub")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your resume will be hosted for free\non GitHub Pages")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Buttons
            VStack(spacing: 16) {
                // Sign In Button - Primary CTA
                Button(action: { authManager.signIn() }) {
                    Label("Sign in with GitHub", systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(authManager.isLoading)
                
                // Create Account Button - Secondary
                Button(action: createGitHubAccount) {
                    Label("Create GitHub Account", systemImage: "person.badge.plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                if authManager.isLoading {
                    ProgressView()
                        .padding(.top, 8)
                }
                
                if let error = authManager.error {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
        }
    }
    
    private func createGitHubAccount() {
        if let url = URL(string: "https://github.com/signup") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(GitHubAuthManager())
}
