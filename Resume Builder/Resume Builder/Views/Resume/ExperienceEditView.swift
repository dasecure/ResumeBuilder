import SwiftUI

struct ExperienceEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State var experience: Experience
    let onSave: (Experience) -> Void
    
    @State private var newHighlight = ""
    @State private var isEnhancing = false
    
    private let aiService = AIService()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Position Details") {
                    TextField("Job Title", text: $experience.title)
                    TextField("Company", text: $experience.company)
                    TextField("Location", text: $experience.location)
                }
                
                Section("Duration") {
                    DatePicker("Start Date", selection: $experience.startDate, displayedComponents: .date)
                    
                    Toggle("I currently work here", isOn: $experience.isCurrentRole)
                    
                    if !experience.isCurrentRole {
                        DatePicker("End Date", selection: Binding(
                            get: { experience.endDate ?? Date() },
                            set: { experience.endDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                
                Section {
                    TextEditor(text: $experience.description)
                        .frame(minHeight: 100)
                } header: {
                    HStack {
                        Text("Description")
                        Spacer()
                        Button(action: enhanceDescription) {
                            HStack(spacing: 4) {
                                if isEnhancing {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                } else {
                                    Image(systemName: "sparkles")
                                }
                                Text("Enhance")
                            }
                            .font(.caption)
                        }
                        .disabled(isEnhancing || experience.description.isEmpty)
                    }
                }
                
                Section("Key Achievements") {
                    ForEach(experience.highlights, id: \.self) { highlight in
                        Text("• \(highlight)")
                    }
                    .onDelete { indexSet in
                        experience.highlights.remove(atOffsets: indexSet)
                    }
                    
                    HStack {
                        TextField("Add achievement", text: $newHighlight)
                        Button(action: addHighlight) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(newHighlight.isEmpty)
                    }
                }
            }
            .navigationTitle(experience.title.isEmpty ? "Add Experience" : "Edit Experience")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(experience)
                        dismiss()
                    }
                    .disabled(experience.title.isEmpty || experience.company.isEmpty)
                }
            }
        }
    }
    
    private func addHighlight() {
        guard !newHighlight.isEmpty else { return }
        experience.highlights.append(newHighlight)
        newHighlight = ""
    }
    
    private func enhanceDescription() {
        isEnhancing = true
        Task {
            do {
                let enhanced = try await aiService.enhanceJobDescription(
                    title: experience.title,
                    company: experience.company,
                    description: experience.description
                )
                await MainActor.run {
                    experience.description = enhanced
                    isEnhancing = false
                }
            } catch {
                isEnhancing = false
            }
        }
    }
}

struct EducationEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State var education: Education
    let onSave: (Education) -> Void
    
    private var isEditing: Bool {
        !education.institution.isEmpty || !education.degree.isEmpty
    }
    
    init(education: Education = Education(), onSave: @escaping (Education) -> Void) {
        _education = State(initialValue: education)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Institution") {
                    TextField("School/University", text: $education.institution)
                    TextField("Degree (e.g., Bachelor of Science)", text: $education.degree)
                    TextField("Field of Study", text: $education.field)
                }
                
                Section("Details") {
                    DatePicker("Graduation Date", selection: Binding(
                        get: { education.graduationDate ?? Date() },
                        set: { education.graduationDate = $0 }
                    ), displayedComponents: .date)
                    
                    TextField("GPA (optional)", text: Binding(
                        get: { education.gpa ?? "" },
                        set: { education.gpa = $0.isEmpty ? nil : $0 }
                    ))
                    .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(isEditing ? "Edit Education" : "Add Education")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(education)
                        dismiss()
                    }
                    .disabled(education.institution.isEmpty || education.degree.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ExperienceEditView(experience: Experience()) { _ in }
}
