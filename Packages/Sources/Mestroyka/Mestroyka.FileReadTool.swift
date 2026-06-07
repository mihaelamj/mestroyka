import Foundation

public extension Mestroyka {
    /// Reads a UTF-8 text file. Reversible (read-only), so it is never gated.
    ///
    /// Arguments: `{"path": "/some/file.txt"}`.
    struct FileReadTool: Tool {
        public let name = "read_file"

        public init() {}

        public func execute(argumentsJSON: String) async -> ToolResult {
            struct Arguments: Decodable { let path: String }
            guard
                let data = argumentsJSON.data(using: .utf8),
                let arguments = try? JSONDecoder().decode(Arguments.self, from: data)
            else {
                return ToolResult(content: "Invalid arguments; expected {\"path\": \"...\"}.", isError: true)
            }
            do {
                let content = try String(contentsOfFile: arguments.path, encoding: .utf8)
                return ToolResult(content: content)
            } catch {
                return ToolResult(content: "Could not read \(arguments.path): \(error.localizedDescription)", isError: true)
            }
        }
    }
}
