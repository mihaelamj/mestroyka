import Foundation

public extension Mestroyka {
    /// Runs a shell command via `/bin/sh -c` and returns its combined output.
    ///
    /// Marked irreversible, so the agent loop routes it through the ``Approver``
    /// before it runs (the model proposes, the host confirms).
    ///
    /// Arguments: `{"command": "ls -la"}`.
    struct ShellTool: Tool {
        public let name = "shell"

        public var isIrreversible: Bool {
            true
        }

        public init() {}

        public func execute(argumentsJSON: String) async -> ToolResult {
            struct Arguments: Decodable { let command: String }
            guard
                let data = argumentsJSON.data(using: .utf8),
                let arguments = try? JSONDecoder().decode(Arguments.self, from: data)
            else {
                return ToolResult(content: "Invalid arguments; expected {\"command\": \"...\"}.", isError: true)
            }
            return await run(arguments.command)
        }

        private func run(_ command: String) async -> ToolResult {
            await withCheckedContinuation { continuation in
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/bin/sh")
                process.arguments = ["-c", command]
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = pipe
                process.terminationHandler = { finished in
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8) ?? ""
                    continuation.resume(returning: ToolResult(
                        content: output,
                        isError: finished.terminationStatus != 0,
                    ))
                }
                do {
                    try process.run()
                } catch {
                    continuation.resume(returning: ToolResult(
                        content: "Failed to run command: \(error.localizedDescription)",
                        isError: true,
                    ))
                }
            }
        }
    }
}
