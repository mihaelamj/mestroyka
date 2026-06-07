public extension Mestroyka {
    /// A capability card the model can choose to read: a name, a one-line
    /// description, and a body of instructions.
    ///
    /// Skills are the open extensibility surface (the procedural-memory library of
    /// Voyager, Wang 2023; the inert, text-only skill model of OpenClaw). They
    /// carry no executable code, so a large catalog is safe by construction. Only
    /// the name and description are kept in context; the body is pulled on demand
    /// when a task matches (progressive disclosure), which is what lets the catalog
    /// scale to thousands without flooding the window.
    struct Skill: Sendable, Equatable {
        /// The skill's short name (the only field, with `description`, always in context).
        public var name: String

        /// A one-line description of when to use the skill.
        public var description: String

        /// The full instructions, read on demand rather than kept in context.
        public var body: String

        /// Creates a skill.
        public init(name: String, description: String, body: String) {
            self.name = name
            self.description = description
            self.body = body
        }

        /// Parses a `SKILL.md`: YAML-ish frontmatter (`name`, `description`) plus a
        /// markdown body. Returns `nil` if there is no frontmatter `name`.
        static func parse(markdown: String) -> Skill? {
            let lines = markdown.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            guard lines.first?.trimmingWhitespace() == "---" else { return nil }
            guard let closing = lines.dropFirst().firstIndex(where: { $0.trimmingWhitespace() == "---" }) else {
                return nil
            }
            let frontmatter = lines[1 ..< closing]
            let body = lines[(closing + 1)...].joined(separator: "\n").trimmingWhitespace()
            var fields: [String: String] = [:]
            for line in frontmatter {
                let parts = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
                guard parts.count == 2 else { continue }
                let key = parts[0].trimmingWhitespace().lowercased()
                let value = unquote(parts[1].trimmingWhitespace())
                if !key.isEmpty { fields[key] = value }
            }
            guard let name = fields["name"], !name.isEmpty else { return nil }
            return Skill(name: name, description: fields["description"] ?? "", body: body)
        }

        /// Renders the always-in-context catalog block (names + descriptions only).
        ///
        /// The body is deliberately omitted: the model is told to read the skill
        /// when a task matches, so the body costs no tokens until it is needed.
        static func availableSkillsPrompt(_ skills: [Skill]) -> String {
            guard !skills.isEmpty else { return "" }
            let entries = skills.map { skill in
                "  <skill>\n    <name>\(skill.name)</name>\n    <description>\(skill.description)</description>\n  </skill>"
            }
            return "<available_skills>\n" + entries.joined(separator: "\n") + "\n</available_skills>"
        }

        private static func unquote(_ value: String) -> String {
            guard value.count >= 2 else { return value }
            let isDoubleQuoted = value.hasPrefix("\"") && value.hasSuffix("\"")
            let isSingleQuoted = value.hasPrefix("'") && value.hasSuffix("'")
            guard isDoubleQuoted || isSingleQuoted else { return value }
            return String(value.dropFirst().dropLast())
        }
    }
}

private extension StringProtocol {
    func trimmingWhitespace() -> String {
        var view = self[...]
        while let first = view.first, first.isWhitespace {
            view = view.dropFirst()
        }
        while let last = view.last, last.isWhitespace {
            view = view.dropLast()
        }
        return String(view)
    }
}
