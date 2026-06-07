public extension Mestroyka {
    /// A complete assistant turn: the text produced, any tools it wants to run,
    /// and why it stopped.
    ///
    /// This is the unit a provider ultimately yields and the agent loop folds back
    /// into the transcript.
    struct AssistantMessage: Sendable, Equatable {
        /// The assistant's text for this turn (may be empty on failure).
        public var text: String

        /// Tools the assistant requested, in order. Empty for a plain text turn.
        public var toolCalls: [ToolCall]

        /// Why the turn ended.
        public var stopReason: StopReason

        /// Creates an assistant message.
        /// - Parameters:
        ///   - text: The assistant's text for this turn.
        ///   - toolCalls: Tools the assistant requested. Defaults to none.
        ///   - stopReason: Why the turn ended.
        public init(text: String, toolCalls: [ToolCall] = [], stopReason: StopReason) {
            self.text = text
            self.toolCalls = toolCalls
            self.stopReason = stopReason
        }
    }
}
