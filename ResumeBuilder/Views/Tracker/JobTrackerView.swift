import SwiftUI

struct JobTrackerView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddApplication = false
    @State private var selectedFilter: ApplicationFilter = .all
    
    enum ApplicationFilter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case interviews = "Interviews"
        case offers = "Offers"
        case closed = "Closed"
    }
    
    var filteredApplications: [JobApplication] {
        switch selectedFilter {
        case .all:
            return dataManager.applications
        case .active:
            return dataManager.applications.filter {
                ![.rejected, .withdrawn, .accepted].contains($0.status)
            }
        case .interviews:
            return dataManager.applications.filter {
                [.phoneScreen, .interview, .technicalInterview, .finalInterview].contains($0.status)
            }
        case .offers:
            return dataManager.applications.filter {
                [.offer, .accepted].contains($0.status)
            }
        case .closed:
            return dataManager.applications.filter {
                [.rejected, .withdrawn, .accepted].contains($0.status)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Stats Header
                StatsHeaderView(dataManager: dataManager)
                
                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ApplicationFilter.allCases, id: \.self) { filter in
                            FilterPill(
                                title: filter.rawValue,
                                isSelected: selectedFilter == filter,
                                count: countFor(filter)
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedFilter = filter
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                
                Divider()
                
                // Applications List
                if filteredApplications.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(filteredApplications) { application in
                            NavigationLink(destination: ApplicationDetailView(application: application)) {
                                ApplicationRow(application: application)
                            }
                        }
                        .onDelete(perform: deleteApplications)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Job Tracker")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddApplication = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddApplication) {
                AddApplicationView()
            }
        }
    }
    
    private func countFor(_ filter: ApplicationFilter) -> Int {
        switch filter {
        case .all: return dataManager.applications.count
        case .active: return dataManager.activeApplicationsCount
        case .interviews: return dataManager.interviewsCount
        case .offers: return dataManager.offersCount
        case .closed:
            return dataManager.applications.filter {
                [.rejected, .withdrawn, .accepted].contains($0.status)
            }.count
        }
    }
    
    private func deleteApplications(at offsets: IndexSet) {
        let appsToDelete = offsets.map { filteredApplications[$0] }
        for app in appsToDelete {
            dataManager.deleteApplication(app)
        }
    }
}

struct StatsHeaderView: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        HStack(spacing: 0) {
            StatBox(value: "\(dataManager.applications.count)", label: "Total", color: .blue)
            Divider().frame(height: 40)
            StatBox(value: "\(dataManager.activeApplicationsCount)", label: "Active", color: .orange)
            Divider().frame(height: 40)
            StatBox(value: "\(dataManager.interviewsCount)", label: "Interviews", color: .purple)
            Divider().frame(height: 40)
            StatBox(value: "\(dataManager.offersCount)", label: "Offers", color: .green)
        }
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground))
    }
}

struct StatBox: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let count: Int
    
    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            if count > 0 {
                Text("\(count)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.3) : Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isSelected ? Color.blue : Color(.systemGray6))
        .foregroundColor(isSelected ? .white : .primary)
        .cornerRadius(20)
    }
}

struct ApplicationRow: View {
    let application: JobApplication
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Icon
            Image(systemName: application.status.icon)
                .font(.title3)
                .foregroundColor(statusColor)
                .frame(width: 40, height: 40)
                .background(statusColor.opacity(0.1))
                .cornerRadius(10)
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(application.position)
                    .font(.headline)
                Text(application.company)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    Text(application.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(statusColor.opacity(0.1))
                        .foregroundColor(statusColor)
                        .cornerRadius(6)
                    
                    Text(application.appliedDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch application.status.color {
        case "blue": return .blue
        case "orange": return .orange
        case "purple": return .purple
        case "green": return .green
        case "red": return .red
        default: return .gray
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "briefcase")
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)
            
            Text("No Applications Yet")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Start tracking your job applications\nto stay organized")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct AddApplicationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    @State private var company = ""
    @State private var position = ""
    @State private var jobURL = ""
    @State private var location = ""
    @State private var isRemote = false
    @State private var salary = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Job Details") {
                    TextField("Company", text: $company)
                    TextField("Position", text: $position)
                    TextField("Job URL (optional)", text: $jobURL)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                }
                
                Section("Location") {
                    TextField("Location", text: $location)
                    Toggle("Remote Position", isOn: $isRemote)
                }
                
                Section("Additional Info") {
                    TextField("Salary Range (optional)", text: $salary)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Application")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        var application = JobApplication(company: company, position: position)
                        application.jobURL = jobURL.isEmpty ? nil : jobURL
                        application.location = location
                        application.isRemote = isRemote
                        application.salary = salary.isEmpty ? nil : salary
                        application.notes = notes
                        
                        dataManager.addApplication(application)
                        dismiss()
                    }
                    .disabled(company.isEmpty || position.isEmpty)
                }
            }
        }
    }
}

struct ApplicationDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @State var application: JobApplication
    @State private var showingStatusPicker = false
    
    var body: some View {
        List {
            // Header
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(application.position)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(application.company)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    if let location = application.location, !location.isEmpty {
                        Label(location, systemImage: "mappin")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    if application.isRemote {
                        Label("Remote", systemImage: "wifi")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Status
            Section("Status") {
                Button(action: { showingStatusPicker = true }) {
                    HStack {
                        Image(systemName: application.status.icon)
                            .foregroundColor(statusColor)
                        Text(application.status.rawValue)
                        Spacer()
                        Text("Change")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Timeline
            Section("Timeline") {
                ForEach(application.events.reversed()) { event in
                    HStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        
                        VStack(alignment: .leading) {
                            Text(event.type.rawValue)
                                .font(.subheadline)
                            Text(event.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            // Notes
            Section("Notes") {
                if application.notes.isEmpty {
                    Text("No notes yet")
                        .foregroundStyle(.secondary)
                } else {
                    Text(application.notes)
                }
            }
            
            // Links
            if let url = application.jobURL, let jobURL = URL(string: url) {
                Section("Links") {
                    Link(destination: jobURL) {
                        Label("View Job Posting", systemImage: "link")
                    }
                }
            }
        }
        .navigationTitle("Application")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingStatusPicker) {
            StatusPickerView(currentStatus: application.status) { newStatus in
                application.updateStatus(newStatus)
                dataManager.updateApplication(application)
            }
        }
    }
    
    private var statusColor: Color {
        switch application.status.color {
        case "blue": return .blue
        case "orange": return .orange
        case "purple": return .purple
        case "green": return .green
        case "red": return .red
        default: return .gray
        }
    }
}

struct StatusPickerView: View {
    let currentStatus: ApplicationStatus
    let onSelect: (ApplicationStatus) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(ApplicationStatus.allCases, id: \.self) { status in
                    Button(action: {
                        onSelect(status)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: status.icon)
                                .foregroundColor(colorFor(status))
                            Text(status.rawValue)
                            Spacer()
                            if status == currentStatus {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Update Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func colorFor(_ status: ApplicationStatus) -> Color {
        switch status.color {
        case "blue": return .blue
        case "orange": return .orange
        case "purple": return .purple
        case "green": return .green
        case "red": return .red
        default: return .gray
        }
    }
}

#Preview {
    JobTrackerView()
        .environmentObject(DataManager())
}
