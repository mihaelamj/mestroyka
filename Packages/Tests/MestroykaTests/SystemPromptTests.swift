@testable import Mestroyka
import Testing

@Suite("system prompt assembly")
struct SystemPromptTests {
    @Test("lists each tool's name and description and the call syntax")
    func listsTools() {
        let prompt = Mestroyka.SystemPrompt.build(tools: [Mestroyka.FileReadTool(), Mestroyka.ShellTool()])
        #expect(prompt.contains("[tool:NAME]"))
        #expect(prompt.contains("read_file"))
        #expect(prompt.contains("shell"))
        #expect(prompt.contains("ls -la")) // from the shell tool's description
    }

    @Test("includes the skill catalog when skills are provided")
    func includesSkills() {
        let skill = Mestroyka.Skill(name: "weather", description: "Look up weather.", body: "secret")
        let prompt = Mestroyka.SystemPrompt.build(tools: [], skills: [skill])
        #expect(prompt.contains("<name>weather</name>"))
        #expect(!prompt.contains("secret")) // progressive disclosure: body excluded
    }

    @Test("with no tools or skills, just the base instruction")
    func baseOnly() {
        let prompt = Mestroyka.SystemPrompt.build(tools: [])
        #expect(prompt.contains("on-device assistant"))
        #expect(!prompt.contains("Available tools"))
    }
}
