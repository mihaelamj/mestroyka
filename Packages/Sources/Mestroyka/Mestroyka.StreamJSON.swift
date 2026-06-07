import Foundation

public extension Mestroyka {
    /// Emits the newline-delimited JSON an agent-spawning host (such as iRelay)
    /// consumes: one JSON object per line, in the simple Codex stream-json shape.
    ///
    /// `{"type":"message","content":"..."}` carries assistant text;
    /// `{"type":"function_call","name":"...","arguments":"..."}` carries a tool
    /// call. This lets mestroyka be driven as a CLI agent over iMessage without
    /// the host knowing anything mestroyka-specific.
    enum StreamJSON {
        /// A line announcing assistant text.
        public static func message(_ content: String) -> String {
            encode(["type": "message", "content": content])
        }

        /// A line announcing a tool call.
        public static func functionCall(name: String, arguments: String) -> String {
            encode(["type": "function_call", "name": name, "arguments": arguments])
        }

        /// All lines for a finished transcript: each tool call, then the final
        /// assistant text.
        public static func lines(for transcript: [Message]) -> [String] {
            var lines: [String] = []
            for entry in transcript {
                guard case let .assistant(assistant) = entry else { continue }
                for call in assistant.toolCalls {
                    lines.append(functionCall(name: call.name, arguments: call.argumentsJSON))
                }
                if !assistant.text.isEmpty {
                    lines.append(message(assistant.text))
                }
            }
            return lines
        }

        private static func encode(_ object: [String: String]) -> String {
            guard
                let data = try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]),
                let string = String(data: data, encoding: .utf8)
            else {
                return "{}"
            }
            return string
        }
    }
}
