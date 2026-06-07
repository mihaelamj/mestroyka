@testable import Mestroyka
import Testing

@Suite("skills: progressive-disclosure capability cards")
struct SkillTests {
    private let card = """
    ---
    name: github
    description: "GitHub CLI for issues, PRs, and releases."
    ---
    # GitHub
    Use `gh` for GitHub work.
    """

    @Test("parses frontmatter name and description and keeps the body")
    func parses() {
        let skill = Mestroyka.Skill.parse(markdown: card)
        #expect(skill?.name == "github")
        #expect(skill?.description == "GitHub CLI for issues, PRs, and releases.")
        #expect(skill?.body.hasPrefix("# GitHub") == true)
    }

    @Test("text without frontmatter is not a skill")
    func noFrontmatter() {
        #expect(Mestroyka.Skill.parse(markdown: "# Just a heading\nbody") == nil)
        #expect(Mestroyka.Skill.parse(markdown: "---\ndescription: no name\n---\nbody") == nil)
    }

    @Test("the catalog prompt carries names and descriptions but not bodies")
    func catalogOmitsBody() {
        let skill = Mestroyka.Skill(name: "weather", description: "Look up weather.", body: "SECRET BODY")
        let prompt = Mestroyka.Skill.availableSkillsPrompt([skill])
        #expect(prompt.contains("<name>weather</name>"))
        #expect(prompt.contains("<description>Look up weather.</description>"))
        #expect(!prompt.contains("SECRET BODY"))
    }

    @Test("an empty catalog renders nothing")
    func emptyCatalog() {
        #expect(Mestroyka.Skill.availableSkillsPrompt([]).isEmpty)
    }
}
