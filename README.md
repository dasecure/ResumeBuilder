# ResumeBuilder

Build and publish your resume to GitHub Pages in minutes. Track job applications and ace your job search.

## Features

### 📝 Resume Builder
- Personal info, experience, education, skills
- AI-powered content enhancement
- Auto-generate professional summaries
- Smart skill suggestions

### 🎨 3 Beautiful Templates
- **Professional** - Clean, corporate look
- **Casual** - Friendly, modern design
- **Playful** - Creative, bold style

### 🚀 One-Tap Publishing
- Deploy to GitHub Pages instantly
- Resume goes LIVE in seconds
- Custom subdomain support
- HTTPS included

### 📤 Easy Sharing
- Copy link, Email, SMS
- LinkedIn & Twitter integration
- QR code generation
- Native share sheet

### 📊 Job Tracker
- Track all applications
- Status pipeline (Applied → Interview → Offer)
- Timeline & notes
- Statistics dashboard

## Screenshots

```
┌─────────────────┬─────────────────┬─────────────────┐
│    Onboarding   │  Resume Editor  │   Templates     │
├─────────────────┼─────────────────┼─────────────────┤
│    Publish      │   Job Tracker   │    Settings     │
└─────────────────┴─────────────────┴─────────────────┘
```

## Setup

### 1. Create GitHub OAuth App

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Click **New OAuth App**
3. Fill in:
   - **Application name:** ResumeBuilder
   - **Homepage URL:** https://dasecure.com
   - **Authorization callback URL:** `resumebuilder://callback`
4. Copy **Client ID** and **Client Secret**

### 2. Create Xcode Project

```
File → New → Project → iOS App
- Name: ResumeBuilder
- Team: DaSecure Solutions LLC
- Bundle ID: com.dasecure.resumebuilder
- Interface: SwiftUI
- Language: Swift
```

### 3. Add Source Files

Copy all files from `ResumeBuilder/` into your Xcode project.

### 4. Configure URL Scheme

In Xcode target → Info → URL Types:
- Identifier: `com.dasecure.resumebuilder`
- URL Schemes: `resumebuilder`

### 5. Add OAuth Credentials

In `Services/GitHubAuthManager.swift`:
```swift
private let clientId = "YOUR_GITHUB_CLIENT_ID"
private let clientSecret = "YOUR_GITHUB_CLIENT_SECRET"
```

### 6. (Optional) Add OpenAI Key

For AI features, add your key in `Services/AIService.swift`:
```swift
private let apiKey = "YOUR_OPENAI_API_KEY"
```

## Project Structure

```
ResumeBuilder/
├── ResumeBuilderApp.swift
├── ContentView.swift
├── Models/
│   ├── Resume.swift           # Resume, Experience, Education
│   ├── JobApplication.swift   # Application tracking
│   ├── GitHubUser.swift
│   └── Portfolio.swift
├── Services/
│   ├── GitHubAuthManager.swift
│   ├── GitHubAPIService.swift
│   ├── AIService.swift
│   ├── DataManager.swift
│   ├── ResumeTemplateGenerator.swift
│   └── KeychainHelper.swift
└── Views/
    ├── Onboarding/
    │   └── OnboardingView.swift
    ├── Resume/
    │   ├── ResumeEditorView.swift
    │   └── ExperienceEditView.swift
    ├── Templates/
    │   └── TemplateGalleryView.swift
    ├── Publish/
    │   └── PublishView.swift
    ├── Tracker/
    │   └── JobTrackerView.swift
    └── Settings/
        └── SettingsView.swift
```

## App Store Submission

**Category:** Productivity / Business

**Keywords:** resume, CV, job search, portfolio, career, GitHub Pages, job tracker

**Privacy:**
- GitHub OAuth (authentication only)
- Optional OpenAI integration
- Local data storage (UserDefaults)
- No ads, no tracking

## Tech Stack

- SwiftUI (iOS 17+)
- GitHub OAuth + REST API
- OpenAI API (optional)
- GitHub Pages hosting

---

Built for the 30-Day SwiftUI Challenge 🚀

Day 1 of 30 | February 6, 2026
