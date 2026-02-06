import SwiftUI

struct ProfileEditorView: View {
    @Binding var portfolio: Portfolio
    
    var body: some View {
        Form {
            Section("Basic Info") {
                TextField("Full Name", text: $portfolio.name)
                    .textContentType(.name)
                
                TextField("Bio / Tagline", text: $portfolio.bio, axis: .vertical)
                    .lineLimit(3...6)
                
                TextField("Location", text: Binding(
                    get: { portfolio.location ?? "" },
                    set: { portfolio.location = $0.isEmpty ? nil : $0 }
                ))
                .textContentType(.addressCity)
            }
            
            Section("Contact") {
                TextField("Email", text: Binding(
                    get: { portfolio.email ?? "" },
                    set: { portfolio.email = $0.isEmpty ? nil : $0 }
                ))
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                
                TextField("Website", text: Binding(
                    get: { portfolio.website ?? "" },
                    set: { portfolio.website = $0.isEmpty ? nil : $0 }
                ))
                .textContentType(.URL)
                .keyboardType(.URL)
                .autocapitalization(.none)
            }
            
            Section("Social") {
                HStack {
                    Image(systemName: "link")
                        .foregroundStyle(.secondary)
                    TextField("LinkedIn URL", text: Binding(
                        get: { portfolio.linkedIn ?? "" },
                        set: { portfolio.linkedIn = $0.isEmpty ? nil : $0 }
                    ))
                    .autocapitalization(.none)
                }
                
                HStack {
                    Image(systemName: "at")
                        .foregroundStyle(.secondary)
                    TextField("Twitter/X username", text: Binding(
                        get: { portfolio.twitter ?? "" },
                        set: { portfolio.twitter = $0.isEmpty ? nil : $0 }
                    ))
                    .autocapitalization(.none)
                }
            }
            
            Section("Skills") {
                SkillsEditor(skills: $portfolio.skills)
            }
        }
    }
}

struct SkillsEditor: View {
    @Binding var skills: [String]
    @State private var newSkill = ""
    
    var body: some View {
        ForEach(skills, id: \.self) { skill in
            HStack {
                Text(skill)
                Spacer()
                Button(action: { skills.removeAll { $0 == skill } }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
            }
        }
        
        HStack {
            TextField("Add skill", text: $newSkill)
            Button(action: addSkill) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
            }
            .disabled(newSkill.isEmpty)
        }
    }
    
    private func addSkill() {
        guard !newSkill.isEmpty else { return }
        skills.append(newSkill)
        newSkill = ""
    }
}

#Preview {
    ProfileEditorView(portfolio: .constant(Portfolio(githubUsername: "demo")))
}
