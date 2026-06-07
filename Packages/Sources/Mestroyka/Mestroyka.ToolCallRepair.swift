import Foundation

public extension Mestroyka {
    /// Recover tool calls that a weak model leaked as plain text.
    ///
    /// A small, local model frequently emits a tool call as prose instead of using
    /// the structured channel: `[tool:weather] {"city":"Zagreb"}`. A naive agent
    /// renders that sentence to the user and runs nothing. Recovering the intended
    /// structured message from a corrupted observation is **noisy-channel
    /// decoding** (Shannon 1948; the maximum-likelihood-over-a-grammar idea behind
    /// Viterbi decoding 1967 and error-recovering parsing, Aho & Ullman).
    ///
    /// The decode is made tractable and *sound* by a codebook: a leaked block is
    /// promoted only if its name is in `allowed`, the exact set of tools offered
    /// this turn. Without that constraint the decoder would fabricate calls to
    /// tools that do not exist. The allowlist is the restricted code that makes the
    /// corruption correctable.
    enum ToolCallRepair {
        /// A recovered tool call.
        struct Call: Equatable {
            /// The tool name (guaranteed to be a member of the allowlist).
            let name: String
            /// The raw JSON arguments object, as leaked.
            let argumentsJSON: String

            init(name: String, argumentsJSON: String) {
                self.name = name
                self.argumentsJSON = argumentsJSON
            }
        }

        /// Largest argument payload to recover, in characters. A leaked block
        /// bigger than this is treated as noise, not a call (over-cap).
        static let maxPayloadCharacters = 256 * 1024

        /// Recovers leaked tool calls from `text`, keeping only those whose name is
        /// in `allowed`.
        /// - Parameters:
        ///   - text: The assistant text to scan.
        ///   - allowed: The names of tools offered this turn (the codebook).
        /// - Returns: The recovered calls, in order of appearance.
        static func repair(text: String, allowed: Set<String>) -> [Call] {
            guard !allowed.isEmpty else { return [] }
            let characters = Array(text)
            let marker = Array("[tool:")
            var calls: [Call] = []
            var cursor = 0
            while cursor < characters.count {
                guard let markerStart = firstIndex(of: marker, in: characters, from: cursor) else { break }
                var index = markerStart + marker.count
                var name = ""
                while index < characters.count, characters[index] != "]" {
                    name.append(characters[index])
                    index += 1
                }
                guard index < characters.count else { break } // no closing ']'
                index += 1 // consume ']'
                while index < characters.count, characters[index].isWhitespace {
                    index += 1
                }
                guard index < characters.count, characters[index] == "{" else {
                    cursor = max(index, markerStart + 1)
                    continue
                }
                guard let jsonEnd = balancedObjectEnd(characters, from: index) else {
                    cursor = max(index, markerStart + 1)
                    continue
                }
                let trimmedName = name.trimmingCharacters(in: .whitespaces)
                if allowed.contains(trimmedName) {
                    calls.append(Call(name: trimmedName, argumentsJSON: String(characters[index ... jsonEnd])))
                }
                cursor = jsonEnd + 1
            }
            return calls
        }

        /// Naive forward search for `pattern` in `characters` starting at `from`.
        private static func firstIndex(of pattern: [Character], in characters: [Character], from: Int) -> Int? {
            guard !pattern.isEmpty, characters.count >= pattern.count else { return nil }
            var start = from
            let last = characters.count - pattern.count
            while start <= last {
                var matched = true
                for offset in 0 ..< pattern.count where characters[start + offset] != pattern[offset] {
                    matched = false
                    break
                }
                if matched { return start }
                start += 1
            }
            return nil
        }

        /// Index of the `}` that closes the `{` at `from`, respecting string
        /// literals and escapes, or `nil` if unbalanced or over the payload cap.
        private static func balancedObjectEnd(_ characters: [Character], from: Int) -> Int? {
            var depth = 0
            var inString = false
            var escaped = false
            var index = from
            while index < characters.count {
                if index - from > maxPayloadCharacters { return nil }
                let character = characters[index]
                if inString {
                    if escaped {
                        escaped = false
                    } else if character == "\\" {
                        escaped = true
                    } else if character == "\"" {
                        inString = false
                    }
                } else {
                    switch character {
                    case "\"": inString = true
                    case "{": depth += 1
                    case "}":
                        depth -= 1
                        if depth == 0 { return index }
                    default: break
                    }
                }
                index += 1
            }
            return nil
        }
    }
}
