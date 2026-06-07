public extension Mestroyka {
    /// The decision cycle: drive the oracle, fold its reply into the transcript.
    ///
    /// This is the irreducible kernel (the recurrence of the agent: query the
    /// oracle, intercept its output, update state). Today it runs a single turn,
    /// because tools are not modelled yet; when tool dispatch lands it becomes the
    /// multi-turn ReAct loop (Yao et al. 2022) bounded by a step cap (Floyd 1967),
    /// continuing only while the oracle requests action.
    struct AgentLoop: Sendable {
        private let oracle: any Oracle

        /// Creates an agent loop.
        /// - Parameter oracle: The model seam to drive. Injected for testability.
        public init(oracle: any Oracle) {
            self.oracle = oracle
        }

        /// Runs one turn and returns the transcript with the assistant's reply appended.
        /// - Parameter messages: The transcript to continue.
        /// - Returns: The transcript plus the assistant turn. Never throws; a
        ///   failure surfaces as an assistant message whose `stopReason` is `.failed`.
        @discardableResult
        public func run(_ messages: [Message]) async -> [Message] {
            var transcript = messages
            var assistant = AssistantMessage(
                text: "",
                stopReason: .failed(
                    reason: "The oracle produced no terminal event.",
                    recovery: "Check the provider implementation; it must yield exactly one `.completed`.",
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
            transcript.append(.assistant(assistant))
            return transcript
        }
    }
}
