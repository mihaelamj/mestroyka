public extension Mestroyka {
    /// A complete assistant turn: the text produced and why it stopped.
    ///
    /// This is the unit a provider ultimately yields and the agent loop folds
    /// back into the transcript. Tool calls are not modelled yet; they arrive
    /// with the next increment.
    struct AssistantMessage: Sendable, Equatable {
        /// The assistant's text for this turn (may be empty on failure).
        public var text: String

        /// Why the turn ended.
        public var stopReason: StopReason

        /// Creates an assistant message.
        /// - Parameters:
        ///   - text: The assistant's text for this turn.
        ///   - stopReason: Why the turn ended.
        public init(text: String, stopReason: StopReason) {
            self.text = text
            self.stopReason = stopReason
        }
    }
}
