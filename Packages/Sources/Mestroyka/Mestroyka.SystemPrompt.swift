public extension Mestroyka {
    /// Assembles the system prompt that makes the agent tool- and skill-aware.
    ///
    /// This is the always-in-context part of the cognitive architecture's context
    /// assembly: the tool list (the operators the model may invoke) and the skill
    /// catalog (progressive disclosure, names and descriptions only). The model is
    /// told to request a tool by emitting a `[tool:NAME] {json}` block, which the
    /// loop recovers with ``ToolCallRepair`` even when the model leaks it as prose.
    enum SystemPrompt {
        /// Builds the system prompt for the given tools and skills.
        public static func build(tools: [any Tool], skills: [Skill] = []) -> String {
            var sections = ["You are mestroyka, a private, on-device assistant. Answer concisely."]
            if !tools.isEmpty {
                let lines = tools
                    .sorted { $0.name < $1.name }
                    .map { "- \($0.name): \($0.description)" }
                    .joined(separator: "\n")
                sections.append(
                    """
                    To use a tool, emit a line of the form [tool:NAME] {"arg": "value"} with JSON \
                    arguments, then stop and wait for the result. Available tools:
                    \(lines)
                    """,
                )
            }
            let catalog = Skill.availableSkillsPrompt(skills)
            if !catalog.isEmpty {
                sections.append("When a task matches a skill, read its file for instructions.\n\(catalog)")
            }
            return sections.joined(separator: "\n\n")
        }
    }
}
