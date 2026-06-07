public extension Mestroyka {
    /// The decision cycle: drive the oracle, run the tools it asks for, repeat
    /// until it stops asking, or until the step bound is hit.
    ///
    /// This is the irreducible kernel: the ReAct recurrence (Yao et al. 2022),
    /// which is the recognize-act / decision cycle of a cognitive architecture
    /// (Soar, Laird et al. 1987). It is bounded by a ranking function on a
    /// well-founded order, a step cap (Floyd 1967), because the oracle could ask
    /// for tools forever and the recurrence otherwise has no termination proof.
    /// Tool calls the oracle leaks as plain text are recovered by ``ToolCallRepair``
    /// against the registered tool names (the codebook).
    struct AgentLoop: Sendable {
        private let oracle: any Oracle
        private let toolsByName: [String: any Tool]
        private let maxSteps: Int

        /// Creates an agent loop.
        /// - Parameters:
        ///   - oracle: The model seam to drive. Injected for testability.
        ///   - tools: The tools the oracle may call. Later names win on collision.
        ///   - maxSteps: The ranking-function bound on tool-using turns.
        public init(oracle: any Oracle, tools: [any Tool] = [], maxSteps: Int = 16) {
            precondition(maxSteps > 0, "maxSteps must be positive")
            self.oracle = oracle
            self.maxSteps = maxSteps
            var table: [String: any Tool] = [:]
            for tool in tools {
                table[tool.name] = tool
            }
            toolsByName = table
        }

        /// Runs the agent to a stop and returns the full transcript.
        ///
        /// Never throws. An oracle failure surfaces as an assistant message with a
        /// `.failed` stop reason; hitting the step bound appends a `.failed` turn
        /// explaining the limit.
        @discardableResult
        func run(_ messages: [Message]) async -> [Message] {
            let allowed = Set(toolsByName.keys)
            var transcript = messages
            var step = 0
            while step < maxSteps {
                step += 1
                let assistant = await streamTurn(transcript)
                transcript.append(.assistant(assistant))
                if case .failed = assistant.stopReason { return transcript }
                let calls = assistant.toolCalls.isEmpty
                    ? recoveredCalls(from: assistant.text, allowed: allowed)
                    : assistant.toolCalls
                guard !calls.isEmpty else { return transcript }
                for call in calls {
                    let result = await dispatch(call)
                    transcript.append(.toolResult(name: call.name, content: result.content))
                }
            }
            transcript.append(.assistant(AssistantMessage(
                text: "",
                stopReason: .failed(
                    reason: "Reached the step limit of \(maxSteps) before the agent finished.",
                    recovery: "Raise maxSteps, simplify the task, or check for a tool loop.",
                ),
            )))
            return transcript
        }

        /// Consumes one oracle turn into a single assistant message.
        private func streamTurn(_ transcript: [Message]) async -> AssistantMessage {
            var assistant = AssistantMessage(
                text: "",
                stopReason: .failed(
                    reason: "The oracle produced no terminal event.",
                    recovery: "The provider must yield exactly one `.completed`.",
                ),
            )
            for await event in oracle.stream(transcript) {
                switch event {
                case let .delta(chunk):
                    assistant.text += chunk
                case let .completed(final):
                    assistant = final
                }
            }
            return assistant
        }

        /// Promotes tool calls leaked as text, gated by the registered tool names.
        private func recoveredCalls(from text: String, allowed: Set<String>) -> [ToolCall] {
            ToolCallRepair.repair(text: text, allowed: allowed).enumerated().map { offset, call in
                ToolCall(id: "repaired-\(offset)", name: call.name, argumentsJSON: call.argumentsJSON)
            }
        }

        /// Runs one call, returning an error result for an unregistered tool.
        private func dispatch(_ call: ToolCall) async -> ToolResult {
            guard let tool = toolsByName[call.name] else {
                return ToolResult(content: "Unknown tool: \(call.name)", isError: true)
            }
            return await tool.execute(argumentsJSON: call.argumentsJSON)
        }
    }
}
