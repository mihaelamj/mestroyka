/// Something the agent can do in the world: a named, callable side effect.
///
/// Tools are the agent's procedural memory (the operators of a cognitive
/// architecture). They are compiled in, not loaded from untrusted third-party
/// code; the open extensibility surface is prose skills the model reads, plus MCP
/// for out-of-process code.
public protocol Tool: Sendable {
    /// The name the oracle uses to call this tool. Must be unique within a loop.
    var name: String { get }

    /// Runs the tool.
    /// - Parameter argumentsJSON: The raw JSON arguments from the call.
    /// - Returns: The outcome. A tool never throws; failure is a `.isError` result.
    func execute(argumentsJSON: String) async -> Mestroyka.ToolResult
}
