import SwiftUI

struct ResumeEditorView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedSection = 0
    @State private var showingPreview = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Section Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        SectionTab(title: "Personal", icon: "person.fill", isSelected: selectedSection == 0)
                            .onTapGesture { selectedSection = 0 }
                        SectionTab(title: "Summary", icon: "text.alignleft", isSelected: selectedSection == 1)
                            .onTapGesture { selectedSection = 1 }
                        SectionTab(title: "Experience", icon: "briefcase.fill", isSelected: selectedSection == 2)
                            .onTapGesture { selectedSection = 2 }
                        SectionTab(title: "Education", icon: "graduationcap.fill", isSelected: selectedSection == 3)
                            .onTapGesture { selectedSection = 3 }
                        SectionTab(title: "Skills", icon: "star.fill", isSelected: selectedSection == 4)
                            .onTapGesture { selectedSection = 4 }
                        SectionTab(title: "Languages", icon: "globe", isSelected: selectedSection == 5)
                            .onTapGesture { selectedSection = 5 }
                        SectionTab(title: "More", icon: "ellipsis.circle.fill", isSelected: selectedSection == 6)
                            .onTapGesture { selectedSection = 6 }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Content
                TabView(selection: $selectedSection) {
                    PersonalInfoSection(info: $dataManager.resume.personalInfo)
                        .tag(0)
                    SummarySection(summary: $dataManager.resume.summary)
                        .tag(1)
                    ExperienceSection(experiences: $dataManager.resume.experiences)
                        .tag(2)
                    EducationSection(education: $dataManager.resume.education)
                        .tag(3)
                    SkillsSection(skills: $dataManager.resume.skills)
                        .tag(4)
                    LanguagesSection(languages: $dataManager.resume.languages)
                        .tag(5)
                    MoreSection(
                        achievements: $dataManager.resume.achievements,
                        patents: $dataManager.resume.patents,
                        hobbies: $dataManager.resume.hobbies
                    )
                        .tag(6)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Build Resume")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dataManager.saveResume()
                        showingPreview = true
                    } label: {
                        Label("Preview", systemImage: "eye.fill")
                    }
                }
            }
            .sheet(isPresented: $showingPreview) {
                ResumePreviewSheet(resume: dataManager.resume)
            }
            .onDisappear {
                dataManager.saveResume()
            }
            .onChange(of: dataManager.resume) { 
                dataManager.saveResume()
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }
}

struct SectionTab: View {
    let title: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                .symbolRenderingMode(.hierarchical)
            Text(title)
                .font(.caption2)
                .fontWeight(isSelected ? .semibold : .medium)
        }
        .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Personal Info Section

struct PersonalInfoSection: View {
    @Binding var info: PersonalInfo
    
    var body: some View {
        Form {
            Section("Basic Information") {
                TextField("Full Name", text: $info.fullName)
                    .textContentType(.name)
                TextField("Email", text: $info.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                TextField("Phone", text: $info.phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                TextField("Location (City, State)", text: $info.location)
                    .textContentType(.addressCityAndState)
            }
            
            Section("Online Presence") {
                TextField("LinkedIn URL", text: $info.linkedIn)
                    .autocapitalization(.none)
                TextField("Personal Website", text: $info.website)
                    .autocapitalization(.none)
                    .keyboardType(.URL)
            }
        }
    }
}

// MARK: - Summary Section

struct SummarySection: View {
    @Binding var summary: String
    @EnvironmentObject var dataManager: DataManager
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var customPrompt = ""
    @State private var showCustomPrompt = false
    
    private let aiService = AIService()
    
    let quickPrompts = [
        "Make it shorter",
        "Make it more professional",
        "Add more impact",
        "Focus on leadership",
        "Highlight technical skills"
    ]
    
    var body: some View {
        Form {
            Section {
                TextEditor(text: $summary)
                    .frame(minHeight: 150)
            } header: {
                Text("Professional Summary")
            } footer: {
                Text("A brief 2-3 sentence overview of your professional background and key strengths.")
            }
            
            Section("AI Assistant") {
                // Quick action buttons
                Button(action: { generateWithAI(prompt: nil) }) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(isGenerating ? "Working..." : (summary.isEmpty ? "Generate with AI" : "Improve with AI"))
                    }
                }
                .disabled(isGenerating || (showCustomPrompt && customPrompt.isEmpty))
                
                // Quick prompts
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(quickPrompts, id: \.self) { prompt in
                            Button(action: { generateWithAI(prompt: prompt) }) {
                                Text(prompt)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(16)
                            }
                            .disabled(isGenerating || summary.isEmpty)
                        }
                    }
                }
                
                // Custom prompt toggle
                Toggle("Custom instruction", isOn: $showCustomPrompt)
                
                if showCustomPrompt {
                    TextField("e.g., Focus on my startup experience", text: $customPrompt)
                    
                    Button(action: { generateWithAI(prompt: customPrompt) }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Apply Custom Instruction")
                        }
                    }
                    .disabled(isGenerating || customPrompt.isEmpty || summary.isEmpty)
                }
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private func generateWithAI(prompt: String?) {
        isGenerating = true
        errorMessage = nil
        Task {
            do {
                let generated: String
                if summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    generated = try await aiService.generateSummary(resume: dataManager.resume)
                } else if let customInstruction = prompt, !customInstruction.isEmpty {
                    generated = try await aiService.customImprove(text: summary, instruction: customInstruction)
                } else {
                    generated = try await aiService.improveSummary(existing: summary, resume: dataManager.resume)
                }
                await MainActor.run {
                    summary = generated
                    isGenerating = false
                    customPrompt = ""
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isGenerating = false
                }
            }
        }
    }
}

// MARK: - Experience Section

struct ExperienceSection: View {
    @Binding var experiences: [Experience]
    @State private var editingExperience: Experience?
    @State private var showingAdd = false
    
    var body: some View {
        List {
            ForEach(experiences) { experience in
                ExperienceRow(experience: experience)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingExperience = experience
                    }
            }
            .onDelete { indexSet in
                experiences.remove(atOffsets: indexSet)
            }
            .onMove { from, to in
                experiences.move(fromOffsets: from, toOffset: to)
            }
            
            Button(action: { showingAdd = true }) {
                Label("Add Experience", systemImage: "plus.circle.fill")
            }
        }
        .sheet(isPresented: $showingAdd) {
            ExperienceEditView(experience: Experience()) { newExp in
                experiences.insert(newExp, at: 0)
            }
        }
        .sheet(item: $editingExperience) { exp in
            ExperienceEditView(experience: exp) { updated in
                if let index = experiences.firstIndex(where: { $0.id == updated.id }) {
                    experiences[index] = updated
                }
            }
        }
    }
}

struct ExperienceRow: View {
    let experience: Experience
    
    private var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        let start = formatter.string(from: experience.startDate)
        let end = experience.isCurrentRole ? "Present" : formatter.string(from: experience.endDate ?? Date())
        return "\(start) - \(end)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(experience.title)
                .font(.headline)
            Text(experience.company)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(dateRange)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Education Section

struct EducationSection: View {
    @Binding var education: [Education]
    @State private var showingAdd = false
    
    var body: some View {
        List {
            ForEach(education) { edu in
                VStack(alignment: .leading, spacing: 4) {
                    Text(edu.degree)
                        .font(.headline)
                    Text(edu.institution)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if !edu.field.isEmpty {
                        Text(edu.field)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)
            }
            .onDelete { indexSet in
                education.remove(atOffsets: indexSet)
            }
            
            Button(action: { showingAdd = true }) {
                Label("Add Education", systemImage: "plus.circle.fill")
            }
        }
        .sheet(isPresented: $showingAdd) {
            EducationEditView { newEdu in
                education.insert(newEdu, at: 0)
            }
        }
    }
}

// MARK: - Skills Section

struct SkillsSection: View {
    @Binding var skills: [String]
    @State private var newSkill = ""
    @State private var suggestedSkills: [String] = []
    @State private var isLoadingSuggestions = false
    
    private let aiService = AIService()
    
    var body: some View {
        Form {
            Section("Your Skills") {
                FlowLayout(spacing: 8) {
                    ForEach(Array(skills.enumerated()), id: \.offset) { index, skill in
                        SkillChip(text: skill) {
                            if index < skills.count {
                                skills.remove(at: index)
                            }
                        }
                    }
                }
                
                HStack {
                    TextField("Add a skill", text: $newSkill)
                        .onSubmit { addSkill() }
                    
                    Button(action: addSkill) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    .disabled(newSkill.isEmpty)
                }
            }
            
            Section("AI Suggestions") {
                if isLoadingSuggestions {
                    ProgressView()
                } else if !suggestedSkills.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(suggestedSkills, id: \.self) { skill in
                            Button(action: { 
                                skills.append(skill)
                                suggestedSkills.removeAll { $0 == skill }
                            }) {
                                Text("+ \(skill)")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.green.opacity(0.1))
                                    .foregroundColor(.green)
                                    .cornerRadius(16)
                            }
                        }
                    }
                } else {
                    Button("Get AI Suggestions") {
                        getSuggestions()
                    }
                }
            }
        }
    }
    
    private func addSkill() {
        guard !newSkill.isEmpty else { return }
        skills.append(newSkill)
        newSkill = ""
    }
    
    private func getSuggestions() {
        isLoadingSuggestions = true
        Task {
            do {
                let suggestions = try await aiService.suggestSkills(for: "Software Engineer", existingSkills: skills)
                await MainActor.run {
                    suggestedSkills = suggestions.filter { !skills.contains($0) }
                    isLoadingSuggestions = false
                }
            } catch {
                isLoadingSuggestions = false
            }
        }
    }
}

// MARK: - Languages Section

struct LanguagesSection: View {
    @Binding var languages: [Language]
    @State private var newLanguage = ""
    @State private var newProficiency: LanguageProficiency = .conversational
    
    var body: some View {
        Form {
            Section("Your Languages") {
                ForEach(languages) { language in
                    HStack {
                        Text(language.name)
                            .font(.headline)
                        Spacer()
                        Text(language.proficiency.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button(action: { languages.removeAll { $0.id == language.id } }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                HStack {
                    TextField("Language", text: $newLanguage)
                    Picker("Level", selection: $newProficiency) {
                        ForEach(LanguageProficiency.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .labelsHidden()
                    Button(action: addLanguage) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                    .disabled(newLanguage.isEmpty)
                }
            }
        }
    }
    
    private func addLanguage() {
        guard !newLanguage.isEmpty else { return }
        languages.append(Language(name: newLanguage, proficiency: newProficiency))
        newLanguage = ""
    }
}

// MARK: - More Section (Achievements, Patents, Hobbies)

struct MoreSection: View {
    @Binding var achievements: [String]
    @Binding var patents: [Patent]
    @Binding var hobbies: [String]
    
    @State private var newAchievement = ""
    @State private var newHobby = ""
    @State private var showingAddPatent = false
    
    var body: some View {
        Form {
            // Achievements
            Section("Achievements") {
                ForEach(achievements, id: \.self) { achievement in
                    HStack {
                        Text(achievement)
                        Spacer()
                        Button(action: { achievements.removeAll { $0 == achievement } }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                HStack {
                    TextField("Add achievement", text: $newAchievement)
                    Button(action: {
                        if !newAchievement.isEmpty {
                            achievements.append(newAchievement)
                            newAchievement = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                    .disabled(newAchievement.isEmpty)
                }
            }
            
            // Patents
            Section("Patents") {
                ForEach(patents) { patent in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(patent.title)
                            .font(.headline)
                        HStack {
                            Text(patent.patentNumber.isEmpty ? "No number" : patent.patentNumber)
                            Text("•")
                            Text(patent.status.rawValue)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                .onDelete { indexSet in
                    patents.remove(atOffsets: indexSet)
                }
                
                Button(action: { showingAddPatent = true }) {
                    Label("Add Patent", systemImage: "plus.circle.fill")
                }
            }
            
            // Hobbies
            Section("Hobbies & Interests") {
                FlowLayout(spacing: 8) {
                    ForEach(Array(hobbies.enumerated()), id: \.offset) { index, hobby in
                        SkillChip(text: hobby) {
                            if index < hobbies.count {
                                hobbies.remove(at: index)
                            }
                        }
                    }
                }
                
                HStack {
                    TextField("Add hobby", text: $newHobby)
                    Button(action: {
                        if !newHobby.isEmpty {
                            hobbies.append(newHobby)
                            newHobby = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                    .disabled(newHobby.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingAddPatent) {
            PatentEditView { newPatent in
                patents.append(newPatent)
            }
        }
    }
}

struct PatentEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var patent = Patent()
    let onSave: (Patent) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Patent Details") {
                    TextField("Title", text: $patent.title)
                    TextField("Patent Number (optional)", text: $patent.patentNumber)
                    Picker("Status", selection: $patent.status) {
                        ForEach(PatentStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
            }
            .navigationTitle("Add Patent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(patent)
                        dismiss()
                    }
                    .disabled(patent.title.isEmpty)
                }
            }
        }
    }
}

struct SkillChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.caption)
                .foregroundColor(.blue)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.blue.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
        .contentShape(Rectangle())
    }
}

// Simple FlowLayout for skills
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, 
                                      y: bounds.minY + result.positions[index].y), 
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var positions: [CGPoint] = []
        var height: CGFloat = 0
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > width && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            height = y + rowHeight
        }
    }
}

#Preview {
    ResumeEditorView()
        .environmentObject(DataManager())
}

// MARK: - Resume Preview Sheet

import WebKit

struct ResumePreviewSheet: View {
    let resume: Resume
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            WebView(html: generateHTML())
                .navigationTitle("Preview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
                .onAppear {
                    print("📋 Preview - Name: \(resume.personalInfo.fullName)")
                    print("📋 Preview - Skills count: \(resume.skills.count)")
                    print("📋 Preview - Skills: \(resume.skills)")
                }
        }
    }
    
    private func generateHTML() -> String {
        let generator = ResumeTemplateGenerator()
        return generator.generate(resume: resume)
    }
}

struct WebView: UIViewRepresentable {
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
