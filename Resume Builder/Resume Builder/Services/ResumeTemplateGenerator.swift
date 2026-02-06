import Foundation

class ResumeTemplateGenerator {
    
    func generate(resume: Resume) -> String {
        switch resume.template {
        case .professional:
            return generateProfessional(resume)
        case .casual:
            return generateCasual(resume)
        case .playful:
            return generatePlayful(resume)
        }
    }
    
    // MARK: - Professional Template
    
    private func generateProfessional(_ r: Resume) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(escape(r.personalInfo.fullName)) - Resume</title>
            <link href="https://fonts.googleapis.com/css2?family=Merriweather:wght@400;700&family=Open+Sans:wght@400;600&display=swap" rel="stylesheet">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body {
                    font-family: 'Open Sans', sans-serif;
                    line-height: 1.6;
                    color: #333;
                    max-width: 800px;
                    margin: 0 auto;
                    padding: 40px 24px;
                    background: #fff;
                }
                header {
                    text-align: center;
                    margin-bottom: 32px;
                    padding-bottom: 24px;
                    border-bottom: 2px solid #0066cc;
                }
                h1 {
                    font-family: 'Merriweather', serif;
                    font-size: 2.5rem;
                    color: #1a1a2e;
                    margin-bottom: 8px;
                }
                .contact {
                    display: flex;
                    justify-content: center;
                    flex-wrap: wrap;
                    gap: 16px;
                    color: #666;
                    font-size: 0.9rem;
                }
                .contact a { color: #0066cc; text-decoration: none; }
                .summary {
                    font-size: 1.05rem;
                    color: #444;
                    margin-bottom: 32px;
                    text-align: center;
                    font-style: italic;
                }
                section { margin-bottom: 28px; }
                h2 {
                    font-family: 'Merriweather', serif;
                    font-size: 1.3rem;
                    color: #0066cc;
                    border-bottom: 1px solid #ddd;
                    padding-bottom: 8px;
                    margin-bottom: 16px;
                    text-transform: uppercase;
                    letter-spacing: 1px;
                }
                .experience-item, .education-item { margin-bottom: 20px; }
                .experience-header, .education-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: baseline;
                    flex-wrap: wrap;
                }
                h3 { font-size: 1.1rem; color: #1a1a2e; }
                .company, .institution { color: #666; font-weight: 600; }
                .date { color: #888; font-size: 0.9rem; }
                .description { margin-top: 8px; color: #444; }
                ul { margin-top: 8px; padding-left: 20px; }
                li { margin-bottom: 4px; color: #444; }
                .skills {
                    display: flex;
                    flex-wrap: wrap;
                    gap: 10px;
                }
                .skill {
                    background: #f0f0f0;
                    padding: 6px 14px;
                    border-radius: 4px;
                    font-size: 0.9rem;
                }
                @media print {
                    body { padding: 0; }
                    header { border-bottom-color: #0066cc; }
                }
            </style>
        </head>
        <body>
            <header>
                <h1>\(escape(r.personalInfo.fullName))</h1>
                <div class="contact">
                    \(r.personalInfo.email.isEmpty ? "" : "<span>\(escape(r.personalInfo.email))</span>")
                    \(r.personalInfo.phone.isEmpty ? "" : "<span>\(escape(r.personalInfo.phone))</span>")
                    \(r.personalInfo.location.isEmpty ? "" : "<span>\(escape(r.personalInfo.location))</span>")
                    \(r.personalInfo.linkedIn.isEmpty ? "" : "<a href=\"\(escape(r.personalInfo.linkedIn))\">LinkedIn</a>")
                    \(r.personalInfo.website.isEmpty ? "" : "<a href=\"\(escape(r.personalInfo.website))\">Website</a>")
                </div>
            </header>
            
            \(r.summary.isEmpty ? "" : "<p class=\"summary\">\(escape(r.summary))</p>")
            
            \(r.experiences.isEmpty ? "" : """
            <section>
                <h2>Experience</h2>
                \(r.experiences.map { exp in
                    let endDate = exp.isCurrentRole ? "Present" : (exp.endDate.map { dateFormatter.string(from: $0) } ?? "")
                    return """
                    <div class="experience-item">
                        <div class="experience-header">
                            <div>
                                <h3>\(escape(exp.title))</h3>
                                <span class="company">\(escape(exp.company))</span>
                            </div>
                            <span class="date">\(dateFormatter.string(from: exp.startDate)) - \(endDate)</span>
                        </div>
                        \(exp.description.isEmpty ? "" : "<p class=\"description\">\(escape(exp.description))</p>")
                        \(exp.highlights.isEmpty ? "" : "<ul>\(exp.highlights.map { "<li>\(escape($0))</li>" }.joined())</ul>")
                    </div>
                    """
                }.joined())
            </section>
            """)
            
            \(r.education.isEmpty ? "" : """
            <section>
                <h2>Education</h2>
                \(r.education.map { edu in
                    return """
                    <div class="education-item">
                        <div class="education-header">
                            <div>
                                <h3>\(escape(edu.degree))\(edu.field.isEmpty ? "" : " in \(escape(edu.field))")</h3>
                                <span class="institution">\(escape(edu.institution))</span>
                            </div>
                            \(edu.graduationDate.map { "<span class=\"date\">\(dateFormatter.string(from: $0))</span>" } ?? "")
                        </div>
                    </div>
                    """
                }.joined())
            </section>
            """)
            
            \(r.skills.isEmpty ? "" : """
            <section>
                <h2>Skills</h2>
                <div class="skills">
                    \(r.skills.map { "<span class=\"skill\">\(escape($0))</span>" }.joined())
                </div>
            </section>
            """)
            
            \(r.languages.isEmpty ? "" : """
            <section>
                <h2>Languages</h2>
                <div class="skills">
                    \(r.languages.map { "<span class=\"skill\">\(escape($0.name)) <small>(\($0.proficiency.rawValue))</small></span>" }.joined())
                </div>
            </section>
            """)
            
            \(r.achievements.isEmpty ? "" : """
            <section>
                <h2>Achievements</h2>
                <ul>
                    \(r.achievements.map { "<li>\(escape($0))</li>" }.joined())
                </ul>
            </section>
            """)
            
            \(r.patents.isEmpty ? "" : """
            <section>
                <h2>Patents</h2>
                \(r.patents.map { patent in
                    return """
                    <div class="experience-item">
                        <h3>\(escape(patent.title))</h3>
                        <p class="meta">\(patent.patentNumber.isEmpty ? "" : "\(escape(patent.patentNumber)) • ")\(patent.status.rawValue)</p>
                    </div>
                    """
                }.joined())
            </section>
            """)
            
            \(r.hobbies.isEmpty ? "" : """
            <section>
                <h2>Hobbies & Interests</h2>
                <div class="skills">
                    \(r.hobbies.map { "<span class=\"skill\">\(escape($0))</span>" }.joined())
                </div>
            </section>
            """)
            
            <footer style="text-align: center; margin-top: 40px; color: #999; font-size: 0.8rem;">
                Built with ResumeBuilder
            </footer>
        </body>
        </html>
        """
    }
    
    // MARK: - Casual Template
    
    private func generateCasual(_ r: Resume) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(escape(r.personalInfo.fullName)) - Resume</title>
            <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body {
                    font-family: 'Poppins', sans-serif;
                    background: linear-gradient(135deg, #e0f7fa 0%, #e8f5e9 100%);
                    min-height: 100vh;
                    padding: 40px 20px;
                }
                .container {
                    max-width: 800px;
                    margin: 0 auto;
                    background: white;
                    border-radius: 24px;
                    padding: 48px;
                    box-shadow: 0 10px 40px rgba(0,0,0,0.1);
                }
                header { text-align: center; margin-bottom: 40px; }
                .avatar {
                    width: 120px;
                    height: 120px;
                    border-radius: 50%;
                    background: linear-gradient(135deg, #00b894, #00cec9);
                    margin: 0 auto 20px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 48px;
                    color: white;
                }
                h1 { font-size: 2.2rem; color: #2d3436; }
                .tagline { color: #00b894; font-weight: 500; margin-top: 8px; }
                .contact {
                    display: flex;
                    justify-content: center;
                    flex-wrap: wrap;
                    gap: 16px;
                    margin-top: 16px;
                }
                .contact a {
                    color: #00b894;
                    text-decoration: none;
                    padding: 8px 16px;
                    background: rgba(0,184,148,0.1);
                    border-radius: 20px;
                    font-size: 0.9rem;
                }
                section { margin-bottom: 32px; }
                h2 {
                    font-size: 1.3rem;
                    color: #00b894;
                    margin-bottom: 20px;
                    display: flex;
                    align-items: center;
                    gap: 10px;
                }
                h2::before {
                    content: '';
                    width: 4px;
                    height: 24px;
                    background: #00b894;
                    border-radius: 2px;
                }
                .card {
                    background: #f8f9fa;
                    border-radius: 16px;
                    padding: 20px;
                    margin-bottom: 16px;
                }
                h3 { color: #2d3436; font-size: 1.1rem; }
                .meta { color: #636e72; font-size: 0.9rem; margin-top: 4px; }
                .description { margin-top: 12px; color: #444; line-height: 1.7; }
                .skills {
                    display: flex;
                    flex-wrap: wrap;
                    gap: 10px;
                }
                .skill {
                    background: linear-gradient(135deg, #00b894, #00cec9);
                    color: white;
                    padding: 8px 18px;
                    border-radius: 25px;
                    font-size: 0.9rem;
                    font-weight: 500;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <header>
                    <div class="avatar">\(String(r.personalInfo.fullName.prefix(1)))</div>
                    <h1>\(escape(r.personalInfo.fullName))</h1>
                    \(r.summary.isEmpty ? "" : "<p class=\"tagline\">\(escape(r.summary))</p>")
                    <div class="contact">
                        \(r.personalInfo.email.isEmpty ? "" : "<a href=\"mailto:\(escape(r.personalInfo.email))\">\(escape(r.personalInfo.email))</a>")
                        \(r.personalInfo.linkedIn.isEmpty ? "" : "<a href=\"\(escape(r.personalInfo.linkedIn))\">LinkedIn</a>")
                        \(r.personalInfo.website.isEmpty ? "" : "<a href=\"\(escape(r.personalInfo.website))\">Portfolio</a>")
                    </div>
                </header>
                
                \(r.experiences.isEmpty ? "" : """
                <section>
                    <h2>Experience</h2>
                    \(r.experiences.map { exp in
                        let endDate = exp.isCurrentRole ? "Present" : (exp.endDate.map { dateFormatter.string(from: $0) } ?? "")
                        return """
                        <div class="card">
                            <h3>\(escape(exp.title))</h3>
                            <p class="meta">\(escape(exp.company)) • \(dateFormatter.string(from: exp.startDate)) - \(endDate)</p>
                            \(exp.description.isEmpty ? "" : "<p class=\"description\">\(escape(exp.description))</p>")
                        </div>
                        """
                    }.joined())
                </section>
                """)
                
                \(r.education.isEmpty ? "" : """
                <section>
                    <h2>Education</h2>
                    \(r.education.map { edu in
                        return """
                        <div class="card">
                            <h3>\(escape(edu.degree))</h3>
                            <p class="meta">\(escape(edu.institution))\(edu.field.isEmpty ? "" : " • \(escape(edu.field))")</p>
                        </div>
                        """
                    }.joined())
                </section>
                """)
                
                \(r.skills.isEmpty ? "" : """
                <section>
                    <h2>Skills</h2>
                    <div class="skills">
                        \(r.skills.map { "<span class=\"skill\">\(escape($0))</span>" }.joined())
                    </div>
                </section>
                """)
            </div>
        </body>
        </html>
        """
    }
    
    // MARK: - Playful Template
    
    private func generatePlayful(_ r: Resume) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(escape(r.personalInfo.fullName)) ✨</title>
            <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body {
                    font-family: 'Space Grotesk', sans-serif;
                    background: #6c5ce7;
                    min-height: 100vh;
                    padding: 40px 20px;
                    color: white;
                }
                .container {
                    max-width: 900px;
                    margin: 0 auto;
                }
                header {
                    text-align: center;
                    padding: 60px 20px;
                    background: linear-gradient(135deg, #a29bfe 0%, #6c5ce7 100%);
                    border-radius: 30px;
                    margin-bottom: 30px;
                    position: relative;
                    overflow: hidden;
                }
                header::before {
                    content: '✨';
                    position: absolute;
                    font-size: 100px;
                    opacity: 0.1;
                    top: -20px;
                    right: -20px;
                }
                h1 {
                    font-size: 3rem;
                    font-weight: 700;
                    margin-bottom: 12px;
                }
                .subtitle {
                    font-size: 1.2rem;
                    opacity: 0.9;
                    max-width: 500px;
                    margin: 0 auto;
                }
                .links {
                    display: flex;
                    justify-content: center;
                    gap: 12px;
                    margin-top: 24px;
                }
                .links a {
                    color: white;
                    background: rgba(255,255,255,0.2);
                    padding: 10px 20px;
                    border-radius: 25px;
                    text-decoration: none;
                    font-weight: 500;
                    transition: all 0.3s;
                }
                .links a:hover { background: rgba(255,255,255,0.3); transform: translateY(-2px); }
                .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; }
                .card {
                    background: rgba(255,255,255,0.1);
                    backdrop-filter: blur(10px);
                    border-radius: 20px;
                    padding: 24px;
                    transition: transform 0.3s;
                }
                .card:hover { transform: translateY(-5px); }
                h2 {
                    font-size: 0.9rem;
                    text-transform: uppercase;
                    letter-spacing: 2px;
                    opacity: 0.7;
                    margin-bottom: 16px;
                }
                h3 { font-size: 1.2rem; margin-bottom: 8px; }
                .meta { opacity: 0.7; font-size: 0.9rem; }
                .description { margin-top: 12px; opacity: 0.9; line-height: 1.6; }
                .skills-section { margin-top: 30px; }
                .skills {
                    display: flex;
                    flex-wrap: wrap;
                    gap: 10px;
                    justify-content: center;
                }
                .skill {
                    background: #fd79a8;
                    padding: 10px 20px;
                    border-radius: 25px;
                    font-weight: 500;
                    transition: transform 0.2s;
                }
                .skill:hover { transform: scale(1.05); }
                footer {
                    text-align: center;
                    margin-top: 40px;
                    opacity: 0.6;
                    font-size: 0.9rem;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <header>
                    <h1>\(escape(r.personalInfo.fullName)) 👋</h1>
                    \(r.summary.isEmpty ? "" : "<p class=\"subtitle\">\(escape(r.summary))</p>")
                    <div class="links">
                        \(r.personalInfo.email.isEmpty ? "" : "<a href=\"mailto:\(escape(r.personalInfo.email))\">📧 Email</a>")
                        \(r.personalInfo.linkedIn.isEmpty ? "" : "<a href=\"\(escape(r.personalInfo.linkedIn))\">💼 LinkedIn</a>")
                        \(r.personalInfo.website.isEmpty ? "" : "<a href=\"\(escape(r.personalInfo.website))\">🌐 Website</a>")
                    </div>
                </header>
                
                <div class="grid">
                    \(r.experiences.map { exp in
                        let endDate = exp.isCurrentRole ? "Present" : (exp.endDate.map { dateFormatter.string(from: $0) } ?? "")
                        return """
                        <div class="card">
                            <h2>💼 Experience</h2>
                            <h3>\(escape(exp.title))</h3>
                            <p class="meta">\(escape(exp.company)) • \(dateFormatter.string(from: exp.startDate)) - \(endDate)</p>
                            \(exp.description.isEmpty ? "" : "<p class=\"description\">\(escape(exp.description))</p>")
                        </div>
                        """
                    }.joined())
                    
                    \(r.education.map { edu in
                        return """
                        <div class="card">
                            <h2>🎓 Education</h2>
                            <h3>\(escape(edu.degree))</h3>
                            <p class="meta">\(escape(edu.institution))</p>
                        </div>
                        """
                    }.joined())
                </div>
                
                \(r.skills.isEmpty ? "" : """
                <div class="skills-section">
                    <div class="card" style="text-align: center;">
                        <h2>⚡ Skills</h2>
                        <div class="skills">
                            \(r.skills.map { "<span class=\"skill\">\(escape($0))</span>" }.joined())
                        </div>
                    </div>
                </div>
                """)
                
                <footer>Made with 💜 using ResumeBuilder</footer>
            </div>
        </body>
        </html>
        """
    }
    
    // MARK: - Helpers
    
    private func escape(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
