import Foundation

enum TemplateGenerator {
    static func generate(portfolio: Portfolio) -> String {
        switch portfolio.theme {
        case .minimal:
            return generateMinimal(portfolio)
        case .modern:
            return generateModern(portfolio)
        case .developer:
            return generateDeveloper(portfolio)
        }
    }
    
    // MARK: - Minimal Theme
    
    private static func generateMinimal(_ p: Portfolio) -> String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(escapeHTML(p.name)) - Portfolio</title>
            <link rel="preconnect" href="https://fonts.googleapis.com">
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body {
                    font-family: 'Inter', -apple-system, sans-serif;
                    line-height: 1.6;
                    color: #1a1a1a;
                    max-width: 720px;
                    margin: 0 auto;
                    padding: 80px 24px;
                }
                .header { text-align: center; margin-bottom: 60px; }
                .avatar {
                    width: 120px; height: 120px;
                    border-radius: 50%;
                    margin-bottom: 24px;
                    object-fit: cover;
                }
                h1 { font-size: 2.5rem; font-weight: 700; margin-bottom: 8px; }
                .bio { color: #666; font-size: 1.1rem; margin-bottom: 24px; }
                .links { display: flex; gap: 16px; justify-content: center; flex-wrap: wrap; }
                .links a {
                    color: #0066cc;
                    text-decoration: none;
                    font-weight: 500;
                }
                .links a:hover { text-decoration: underline; }
                .section { margin-bottom: 48px; }
                .section h2 {
                    font-size: 1.25rem;
                    font-weight: 600;
                    margin-bottom: 24px;
                    padding-bottom: 8px;
                    border-bottom: 2px solid #eee;
                }
                .skills { display: flex; flex-wrap: wrap; gap: 8px; }
                .skill {
                    background: #f0f0f0;
                    padding: 6px 14px;
                    border-radius: 20px;
                    font-size: 0.9rem;
                }
                .project {
                    padding: 20px 0;
                    border-bottom: 1px solid #eee;
                }
                .project:last-child { border-bottom: none; }
                .project h3 { font-size: 1.1rem; font-weight: 600; margin-bottom: 6px; }
                .project p { color: #666; font-size: 0.95rem; }
                .project-link {
                    display: inline-block;
                    margin-top: 8px;
                    color: #0066cc;
                    text-decoration: none;
                    font-size: 0.9rem;
                }
                .footer {
                    margin-top: 60px;
                    text-align: center;
                    color: #999;
                    font-size: 0.85rem;
                }
            </style>
        </head>
        <body>
            <header class="header">
                \(p.avatarURL != nil ? "<img src=\"\(p.avatarURL!)\" alt=\"\(escapeHTML(p.name))\" class=\"avatar\">" : "")
                <h1>\(escapeHTML(p.name))</h1>
                <p class="bio">\(escapeHTML(p.bio))</p>
                <div class="links">
                    \(generateLinks(p))
                </div>
            </header>
            
            \(p.skills.isEmpty ? "" : """
            <section class="section">
                <h2>Skills</h2>
                <div class="skills">
                    \(p.skills.map { "<span class=\"skill\">\(escapeHTML($0))</span>" }.joined(separator: "\n                    "))
                </div>
            </section>
            """)
            
            \(p.projects.isEmpty ? "" : """
            <section class="section">
                <h2>Projects</h2>
                \(p.projects.map { generateProjectHTML($0) }.joined(separator: "\n            "))
            </section>
            """)
            
            <footer class="footer">
                Built with ResumeBuilder
            </footer>
        </body>
        </html>
        """
    }
    
    // MARK: - Modern Theme
    
    private static func generateModern(_ p: Portfolio) -> String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(escapeHTML(p.name))</title>
            <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body {
                    font-family: 'Poppins', sans-serif;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    min-height: 100vh;
                    padding: 40px 20px;
                }
                .container {
                    max-width: 900px;
                    margin: 0 auto;
                    background: white;
                    border-radius: 24px;
                    padding: 60px;
                    box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
                }
                .header { text-align: center; margin-bottom: 48px; }
                .avatar {
                    width: 140px; height: 140px;
                    border-radius: 50%;
                    border: 4px solid #667eea;
                    margin-bottom: 24px;
                }
                h1 { font-size: 2.5rem; color: #1a1a2e; }
                .bio { color: #666; font-size: 1.1rem; margin: 16px 0 24px; }
                .links { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }
                .links a {
                    background: linear-gradient(135deg, #667eea, #764ba2);
                    color: white;
                    padding: 10px 20px;
                    border-radius: 25px;
                    text-decoration: none;
                    font-weight: 500;
                    transition: transform 0.2s;
                }
                .links a:hover { transform: translateY(-2px); }
                .section { margin-bottom: 40px; }
                .section h2 {
                    font-size: 1.5rem;
                    color: #667eea;
                    margin-bottom: 20px;
                }
                .skills { display: flex; flex-wrap: wrap; gap: 10px; }
                .skill {
                    background: linear-gradient(135deg, #667eea20, #764ba220);
                    color: #667eea;
                    padding: 8px 18px;
                    border-radius: 20px;
                    font-weight: 500;
                }
                .projects { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 24px; }
                .project {
                    background: #f8f9fa;
                    padding: 24px;
                    border-radius: 16px;
                    transition: transform 0.2s;
                }
                .project:hover { transform: translateY(-4px); }
                .project h3 { color: #1a1a2e; margin-bottom: 8px; }
                .project p { color: #666; font-size: 0.95rem; }
                .footer { text-align: center; color: #999; margin-top: 40px; }
            </style>
        </head>
        <body>
            <div class="container">
                <header class="header">
                    \(p.avatarURL != nil ? "<img src=\"\(p.avatarURL!)\" alt=\"\" class=\"avatar\">" : "")
                    <h1>\(escapeHTML(p.name))</h1>
                    <p class="bio">\(escapeHTML(p.bio))</p>
                    <div class="links">\(generateLinks(p))</div>
                </header>
                
                \(p.skills.isEmpty ? "" : """
                <section class="section">
                    <h2>✨ Skills</h2>
                    <div class="skills">\(p.skills.map { "<span class=\"skill\">\(escapeHTML($0))</span>" }.joined())</div>
                </section>
                """)
                
                \(p.projects.isEmpty ? "" : """
                <section class="section">
                    <h2>🚀 Projects</h2>
                    <div class="projects">\(p.projects.map { generateModernProjectHTML($0) }.joined())</div>
                </section>
                """)
                
                <footer class="footer">Built with ResumeBuilder</footer>
            </div>
        </body>
        </html>
        """
    }
    
    // MARK: - Developer Theme
    
    private static func generateDeveloper(_ p: Portfolio) -> String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(escapeHTML(p.name)) | Developer</title>
            <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body {
                    font-family: 'Inter', sans-serif;
                    background: #0d1117;
                    color: #c9d1d9;
                    line-height: 1.6;
                }
                .container { max-width: 1000px; margin: 0 auto; padding: 60px 24px; }
                .terminal {
                    background: #161b22;
                    border: 1px solid #30363d;
                    border-radius: 12px;
                    padding: 24px;
                    margin-bottom: 32px;
                    font-family: 'JetBrains Mono', monospace;
                }
                .terminal-header {
                    display: flex;
                    gap: 8px;
                    margin-bottom: 16px;
                }
                .dot { width: 12px; height: 12px; border-radius: 50%; }
                .dot.red { background: #ff5f56; }
                .dot.yellow { background: #ffbd2e; }
                .dot.green { background: #27ca40; }
                .prompt { color: #58a6ff; }
                .cmd { color: #7ee787; }
                h1 { font-size: 2rem; color: #f0f6fc; margin: 8px 0; }
                .bio { color: #8b949e; }
                .links { margin-top: 16px; }
                .links a {
                    color: #58a6ff;
                    text-decoration: none;
                    margin-right: 16px;
                }
                .links a:hover { text-decoration: underline; }
                .section h2 {
                    font-family: 'JetBrains Mono', monospace;
                    color: #7ee787;
                    font-size: 1rem;
                    margin-bottom: 16px;
                }
                .section h2::before { content: '// '; color: #6e7681; }
                .skills { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 32px; }
                .skill {
                    background: #21262d;
                    border: 1px solid #30363d;
                    padding: 6px 14px;
                    border-radius: 6px;
                    font-family: 'JetBrains Mono', monospace;
                    font-size: 0.85rem;
                    color: #58a6ff;
                }
                .projects { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 16px; }
                .project {
                    background: #161b22;
                    border: 1px solid #30363d;
                    border-radius: 8px;
                    padding: 20px;
                }
                .project h3 {
                    color: #58a6ff;
                    font-size: 1.1rem;
                    display: flex;
                    align-items: center;
                    gap: 8px;
                }
                .project h3::before { content: '📁'; }
                .project p { color: #8b949e; font-size: 0.9rem; margin: 8px 0; }
                .tech { display: flex; gap: 8px; margin-top: 12px; }
                .tech span {
                    font-size: 0.75rem;
                    color: #7ee787;
                    background: #238636;
                    padding: 2px 8px;
                    border-radius: 4px;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="terminal">
                    <div class="terminal-header">
                        <span class="dot red"></span>
                        <span class="dot yellow"></span>
                        <span class="dot green"></span>
                    </div>
                    <p><span class="prompt">~</span> <span class="cmd">whoami</span></p>
                    <h1>\(escapeHTML(p.name))</h1>
                    <p class="bio">\(escapeHTML(p.bio))</p>
                    <div class="links">\(generateLinks(p))</div>
                </div>
                
                \(p.skills.isEmpty ? "" : """
                <section class="section">
                    <h2>tech_stack</h2>
                    <div class="skills">\(p.skills.map { "<span class=\"skill\">\(escapeHTML($0))</span>" }.joined())</div>
                </section>
                """)
                
                \(p.projects.isEmpty ? "" : """
                <section class="section">
                    <h2>projects</h2>
                    <div class="projects">\(p.projects.map { generateDevProjectHTML($0) }.joined())</div>
                </section>
                """)
            </div>
        </body>
        </html>
        """
    }
    
    // MARK: - Helpers
    
    private static func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
    
    private static func generateLinks(_ p: Portfolio) -> String {
        var links: [String] = []
        
        links.append("<a href=\"https://github.com/\(p.githubUsername)\">GitHub</a>")
        
        if let email = p.email, !email.isEmpty {
            links.append("<a href=\"mailto:\(email)\">Email</a>")
        }
        if let linkedin = p.linkedIn, !linkedin.isEmpty {
            links.append("<a href=\"\(linkedin)\">LinkedIn</a>")
        }
        if let twitter = p.twitter, !twitter.isEmpty {
            links.append("<a href=\"https://twitter.com/\(twitter)\">Twitter</a>")
        }
        if let website = p.website, !website.isEmpty {
            links.append("<a href=\"\(website)\">Website</a>")
        }
        
        return links.joined(separator: "\n                    ")
    }
    
    private static func generateProjectHTML(_ project: Project) -> String {
        """
        <div class="project">
            <h3>\(escapeHTML(project.name))\(project.featured ? " ⭐" : "")</h3>
            <p>\(escapeHTML(project.description))</p>
            \(project.url != nil || project.repoURL != nil ?
                "<a href=\"\(project.url ?? project.repoURL!)\" class=\"project-link\">View Project →</a>" : "")
        </div>
        """
    }
    
    private static func generateModernProjectHTML(_ project: Project) -> String {
        """
        <div class="project">
            <h3>\(escapeHTML(project.name))\(project.featured ? " ⭐" : "")</h3>
            <p>\(escapeHTML(project.description))</p>
        </div>
        """
    }
    
    private static func generateDevProjectHTML(_ project: Project) -> String {
        """
        <div class="project">
            <h3>\(escapeHTML(project.name))</h3>
            <p>\(escapeHTML(project.description))</p>
            \(!project.technologies.isEmpty ? "<div class=\"tech\">\(project.technologies.map { "<span>\(escapeHTML($0))</span>" }.joined())</div>" : "")
        </div>
        """
    }
}
