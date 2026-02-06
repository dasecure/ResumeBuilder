import SwiftUI

struct ThemePickerView: View {
    @Binding var selectedTheme: Theme
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(Theme.allCases, id: \.self) { theme in
                    ThemeCard(
                        theme: theme,
                        isSelected: selectedTheme == theme
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTheme = theme
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct ThemeCard: View {
    let theme: Theme
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Theme Preview
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeBackground)
                    .frame(height: 160)
                
                VStack(spacing: 8) {
                    Circle()
                        .fill(themeAccent)
                        .frame(width: 40, height: 40)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(themeText.opacity(0.8))
                        .frame(width: 80, height: 12)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(themeText.opacity(0.4))
                        .frame(width: 100, height: 8)
                    
                    HStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(themeAccent.opacity(0.3))
                                .frame(width: 30, height: 20)
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
            
            // Theme Name
            HStack {
                Text(theme.rawValue)
                    .font(.headline)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var themeBackground: Color {
        switch theme {
        case .minimal: return Color(.systemBackground)
        case .modern: return Color(.systemGray6)
        case .developer: return Color(red: 0.1, green: 0.1, blue: 0.15)
        }
    }
    
    private var themeAccent: Color {
        switch theme {
        case .minimal: return .blue
        case .modern: return .purple
        case .developer: return .green
        }
    }
    
    private var themeText: Color {
        switch theme {
        case .minimal: return .primary
        case .modern: return .primary
        case .developer: return .white
        }
    }
}

#Preview {
    ThemePickerView(selectedTheme: .constant(.minimal))
}
