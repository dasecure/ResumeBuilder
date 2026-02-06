import SwiftUI

struct ProjectsEditorView: View {
    @Binding var projects: [Project]
    @State private var editingProject: Project?
    @State private var showingAddProject = false
    
    var body: some View {
        List {
            ForEach($projects) { $project in
                ProjectRow(project: $project)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingProject = project
                    }
            }
            .onDelete(perform: deleteProjects)
            .onMove(perform: moveProjects)
            
            Button(action: { showingAddProject = true }) {
                Label("Add Project", systemImage: "plus.circle.fill")
            }
        }
        .sheet(item: $editingProject) { project in
            ProjectEditSheet(project: project) { updated in
                if let index = projects.firstIndex(where: { $0.id == updated.id }) {
                    projects[index] = updated
                }
            }
        }
        .sheet(isPresented: $showingAddProject) {
            ProjectEditSheet(project: Project()) { newProject in
                projects.append(newProject)
            }
        }
    }
    
    private func deleteProjects(at offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
    }
    
    private func moveProjects(from source: IndexSet, to destination: Int) {
        projects.move(fromOffsets: source, toOffset: destination)
    }
}

struct ProjectRow: View {
    @Binding var project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(project.name.isEmpty ? "Untitled Project" : project.name)
                    .font(.headline)
                
                Spacer()
                
                if project.featured {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
            
            if !project.description.isEmpty {
                Text(project.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            if !project.technologies.isEmpty {
                HStack {
                    ForEach(project.technologies.prefix(3), id: \.self) { tech in
                        Text(tech)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ProjectEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State var project: Project
    let onSave: (Project) -> Void
    
    @State private var newTech = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Project Name", text: $project.name)
                    TextField("Description", text: $project.description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Project URL", text: Binding(
                        get: { project.url ?? "" },
                        set: { project.url = $0.isEmpty ? nil : $0 }
                    ))
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    
                    Toggle("Featured Project", isOn: $project.featured)
                }
                
                Section("Technologies") {
                    ForEach(project.technologies, id: \.self) { tech in
                        HStack {
                            Text(tech)
                            Spacer()
                            Button(action: { project.technologies.removeAll { $0 == tech } }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("Add technology", text: $newTech)
                        Button(action: {
                            if !newTech.isEmpty {
                                project.technologies.append(newTech)
                                newTech = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle(project.name.isEmpty ? "New Project" : "Edit Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(project)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProjectsEditorView(projects: .constant([
        Project(name: "Cool App", description: "A very cool app")
    ]))
}
