import SwiftUI

struct PublishView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: GitHubAuthManager
    @State private var isPublishing = false
    @State private var showError = false
    @State private var showSuccess = false
    @State private var errorMessage = ""
    @State private var showShareSheet = false
    @State private var showSubdomainSetup = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Status Card
                    StatusCard(
                        isPublished: dataManager.resume.isPublished,
                        url: dataManager.resume.publishedURL,
                        customDomain: dataManager.resume.customDomain
                    )
                    
                    // Actions
                    VStack(spacing: 16) {
                        // Publish Button - Primary CTA
                        Button(action: publish) {
                            if isPublishing {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 4)
                            } else {
                                Label(
                                    dataManager.resume.isPublished ? "Update Resume" : "Publish to Web",
                                    systemImage: dataManager.resume.isPublished ? "arrow.triangle.2.circlepath" : "globe"
                                )
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(isPublishing)
                        
                        if dataManager.resume.isPublished {
                            // Share Button
                            Button(action: { showShareSheet = true }) {
                                Label("Share Resume", systemImage: "square.and.arrow.up")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 4)
                            }
                            .buttonStyle(.bordered)
                            .tint(.green)
                            .controlSize(.large)
                            
                            // Custom Domain Button
                            Button(action: { showSubdomainSetup = true }) {
                                Label("Custom Domain", systemImage: "link.badge.plus")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 4)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Quick Links
                    if dataManager.resume.isPublished, let url = dataManager.resume.publishedURL {
                        QuickLinksSection(url: url)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Publish")
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Published! 🎉", isPresented: $showSuccess) {
                Button("View Site") {
                    if let url = URL(string: dataManager.resume.publishedURL ?? "") {
                        UIApplication.shared.open(url)
                    }
                }
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your \(dataManager.resume.template.rawValue) resume is live!\n\nNote: May take 1-2 min to update due to caching.")
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = dataManager.resume.publishedURL {
                    ShareSheet(url: url, resume: dataManager.resume)
                }
            }
            .sheet(isPresented: $showSubdomainSetup) {
                SubdomainSetupView()
            }
        }
    }
    
    private func publish() {
        guard let token = authManager.getAccessToken(),
              let username = authManager.user?.login else {
            errorMessage = "Please sign in to publish"
            showError = true
            return
        }
        
        // Save any pending changes first
        dataManager.saveResume()
        
        isPublishing = true
        
        Task {
            do {
                let apiService = GitHubAPIService(accessToken: token)
                let generator = ResumeTemplateGenerator()
                let html = generator.generate(resume: dataManager.resume)
                
                print("📄 Publishing resume for: \(dataManager.resume.personalInfo.fullName)")
                print("📝 Summary: \(dataManager.resume.summary.prefix(50))...")
                print("🎨 Template: \(dataManager.resume.template.rawValue)")
                print("🔧 Skills: \(dataManager.resume.skills)")
                
                let url = try await apiService.deployPortfolio(
                    username: username,
                    portfolio: Portfolio(githubUsername: username), // Legacy compatibility
                    htmlContent: html
                )
                
                await MainActor.run {
                    dataManager.resume.isPublished = true
                    dataManager.resume.publishedURL = url
                    dataManager.saveResume()
                    isPublishing = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isPublishing = false
                }
            }
        }
    }
}

struct StatusCard: View {
    let isPublished: Bool
    let url: String?
    let customDomain: String?
    
    var body: some View {
        VStack(spacing: 16) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(isPublished ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: isPublished ? "checkmark.circle.fill" : "globe")
                    .font(.system(size: 40))
                    .foregroundColor(isPublished ? .green : .gray)
            }
            
            // Status Text
            VStack(spacing: 4) {
                Text(isPublished ? "Resume is LIVE" : "Not Published Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let url = customDomain ?? url {
                    Link(url, destination: URL(string: url.hasPrefix("http") ? url : "https://\(url)")!)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if isPublished {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Online")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct QuickLinksSection: View {
    let url: String
    @State private var showingQRCode = false
    @State private var showingCopied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Share")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ShareLinkButton(icon: "doc.on.doc", title: showingCopied ? "Copied!" : "Copy Link", color: .blue) {
                        UIPasteboard.general.string = url
                        showingCopied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showingCopied = false
                        }
                    }
                    
                    ShareLinkButton(icon: "envelope.fill", title: "Email", color: .orange) {
                        if let mailURL = URL(string: "mailto:?subject=My Resume&body=Check out my resume: \(url)") {
                            UIApplication.shared.open(mailURL)
                        }
                    }
                    
                    ShareLinkButton(icon: "link", title: "LinkedIn", color: Color(red: 0, green: 0.47, blue: 0.71)) {
                        if let linkedInURL = URL(string: "https://www.linkedin.com/sharing/share-offsite/?url=\(url)") {
                            UIApplication.shared.open(linkedInURL)
                        }
                    }
                    
                    ShareLinkButton(icon: "bubble.left.fill", title: "Twitter", color: .black) {
                        if let twitterURL = URL(string: "https://twitter.com/intent/tweet?text=Check out my resume&url=\(url)") {
                            UIApplication.shared.open(twitterURL)
                        }
                    }
                    
                    ShareLinkButton(icon: "qrcode", title: "QR Code", color: .purple) {
                        showingQRCode = true
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingQRCode) {
            QRCodeView(url: url)
        }
    }
}

// MARK: - QR Code View

import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let url: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // QR Code
                if let qrImage = generateQRCode(from: url) {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                }
                
                // URL
                Text(url)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                // Actions
                VStack(spacing: 12) {
                    Button {
                        if let qrImage = generateQRCode(from: url) {
                            let activityVC = UIActivityViewController(activityItems: [qrImage], applicationActivities: nil)
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                window.rootViewController?.present(activityVC, animated: true)
                            }
                        }
                    } label: {
                        Label("Share QR Code", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button {
                        if let qrImage = generateQRCode(from: url) {
                            UIImageWriteToSavedPhotosAlbum(qrImage, nil, nil, nil)
                        }
                    } label: {
                        Label("Save to Photos", systemImage: "photo.badge.arrow.down")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .navigationTitle("QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Scale up the QR code
        let scale = 10.0
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}

struct ShareLinkButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(width: 70, height: 70)
            .foregroundColor(color)
            .background(color.opacity(0.1))
            .cornerRadius(16)
        }
    }
}

struct ShareSheet: View {
    let url: String
    let resume: Resume
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Share Link") {
                    Button(action: { UIPasteboard.general.string = url }) {
                        Label("Copy to Clipboard", systemImage: "doc.on.doc")
                    }
                    
                    Button(action: shareViaSystem) {
                        Label("Share via...", systemImage: "square.and.arrow.up")
                    }
                }
                
                Section("Social Media") {
                    Button(action: shareToLinkedIn) {
                        Label("Share on LinkedIn", systemImage: "link")
                    }
                    
                    Button(action: shareToTwitter) {
                        Label("Share on Twitter", systemImage: "at")
                    }
                }
                
                Section("Direct") {
                    Button(action: shareViaEmail) {
                        Label("Send via Email", systemImage: "envelope")
                    }
                    
                    Button(action: shareViaSMS) {
                        Label("Send via SMS", systemImage: "message")
                    }
                }
            }
            .navigationTitle("Share Resume")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func shareViaSystem() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let url = URL(string: url) else { return }
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        window.rootViewController?.present(activityVC, animated: true)
    }
    
    private func shareToLinkedIn() {
        if let linkedInURL = URL(string: "https://www.linkedin.com/sharing/share-offsite/?url=\(url)") {
            UIApplication.shared.open(linkedInURL)
        }
    }
    
    private func shareToTwitter() {
        if let twitterURL = URL(string: "https://twitter.com/intent/tweet?text=Check out my resume&url=\(url)") {
            UIApplication.shared.open(twitterURL)
        }
    }
    
    private func shareViaEmail() {
        let subject = "My Resume - \(resume.personalInfo.fullName)"
        let body = "Hi,\n\nPlease check out my resume at: \(url)\n\nBest regards,\n\(resume.personalInfo.fullName)"
        if let mailURL = URL(string: "mailto:?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(mailURL)
        }
    }
    
    private func shareViaSMS() {
        if let smsURL = URL(string: "sms:&body=Check out my resume: \(url)") {
            UIApplication.shared.open(smsURL)
        }
    }
}

struct SubdomainSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subdomain = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("yourname", text: $subdomain)
                        .autocapitalization(.none)
                } header: {
                    Text("Custom Subdomain")
                } footer: {
                    Text("Your resume will be available at \(subdomain.isEmpty ? "yourname" : subdomain).yourdomain.com")
                }
                
                Section {
                    Text("To set up a custom domain, you'll need to:")
                        .font(.subheadline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Add a CNAME record pointing to your GitHub Pages", systemImage: "1.circle.fill")
                        Label("Configure the domain in your repository settings", systemImage: "2.circle.fill")
                        Label("Wait for DNS propagation (up to 24 hours)", systemImage: "3.circle.fill")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Custom Domain")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // TODO: Configure CNAME
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PublishView()
        .environmentObject(DataManager())
        .environmentObject(GitHubAuthManager())
}
