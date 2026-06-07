/// Something the agent can do in the world: a named, callable side effect.
///
/// Tools are the agent's procedural memory (the operators of a cognitive
/// architecture). They are compiled in, not loaded from untrusted third-party
/// code; the open extensibility surface is prose skills the model reads, plus MCP
/// for out-of-process code.
public protocol Tool: Sendable {
    /// The name the oracle uses to call this tool. Must be unique within a loop.
    var name: String { get }

    /// A one-line description, including the expected JSON arguments, shown to the
    /// model so it knows when and how to call the tool.
    var description: String { get }

    /// Whether running this tool changes or sends data in a way that is hard to
    /// undo. Irreversible tools are gated behind an ``Approver`` (a reference
    /// monitor, Anderson 1972): the model proposes, the host confirms.
    var isIrreversible: Bool { get }

    /// Runs the tool.
    /// - Parameter argumentsJSON: The raw JSON arguments from the call.
    /// - Returns: The outcome. A tool never throws; failure is a `.isError` result.
    func execute(argumentsJSON: String) async -> Mestroyka.ToolResult
}

public extension Tool {
    /// Tools are read-only by default; opt in to gating by overriding this.
    var isIrreversible: Bool {
        false
    }

    /// Tools have no description by default.
    var description: String {
        ""
    }
}
