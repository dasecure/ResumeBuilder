import SwiftUI

struct TemplateGalleryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingPreview = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(ResumeTemplate.allCases, id: \.self) { template in
                        TemplateCard(
                            template: template,
                            isSelected: dataManager.resume.template == template
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                dataManager.resume.template = template
                                dataManager.saveResume()
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Templates")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingPreview = true
                    } label: {
                        Label("Preview", systemImage: "eye.fill")
                    }
                }
            }
            .sheet(isPresented: $showingPreview) {
                ResumePreviewView(resume: dataManager.resume)
            }
        }
    }
}

struct TemplateCard: View {
    let template: ResumeTemplate
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Preview
            TemplatePreview(template: template)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            // Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(template.rawValue)
                            .font(.headline)
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Text(template.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 12)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
        )
    }
}

struct TemplatePreview: View {
    let template: ResumeTemplate
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundColor
                
                VStack(spacing: 12) {
                    // Header
                    Circle()
                        .fill(accentColor)
                        .frame(width: 40, height: 40)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(textColor)
                        .frame(width: 100, height: 14)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(textColor.opacity(0.5))
                        .frame(width: 150, height: 8)
                    
                    Spacer().frame(height: 10)
                    
                    // Content blocks
                    HStack(spacing: 12) {
                        VStack(spacing: 6) {
                            ForEach(0..<4) { _ in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(textColor.opacity(0.3))
                                    .frame(height: 6)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 6) {
                            ForEach(0..<4) { _ in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(textColor.opacity(0.3))
                                    .frame(height: 6)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                }
                .padding()
            }
        }
    }
    
    private var backgroundColor: Color {
        switch template {
        case .professional: return Color(.systemBackground)
        case .casual: return Color(red: 0.95, green: 0.97, blue: 0.98)
        case .playful: return Color(red: 0.43, green: 0.36, blue: 0.9)
        }
    }
    
    private var accentColor: Color {
        switch template {
        case .professional: return .blue
        case .casual: return Color(red: 0, green: 0.72, blue: 0.58)
        case .playful: return Color(red: 0.99, green: 0.47, blue: 0.66)
        }
    }
    
    private var textColor: Color {
        switch template {
        case .professional, .casual: return .primary
        case .playful: return .white
        }
    }
}

import WebKit

struct ResumePreviewView: View {
    let resume: Resume
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TemplateWebView(html: generateHTML())
                .navigationTitle("\(resume.template.rawValue) Preview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
    
    private func generateHTML() -> String {
        let generator = ResumeTemplateGenerator()
        return generator.generate(resume: resume)
    }
}

struct TemplateWebView: UIViewRepresentable {
    let html: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: nil)
    }
}

#Preview {
    TemplateGalleryView()
        .environmentObject(DataManager())
}
