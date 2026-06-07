public extension Mestroyka {
    /// An incremental event emitted by an ``Oracle`` while it produces a turn.
    ///
    /// The stream always ends with exactly one `.completed`. A provider never
    /// throws: a failure is delivered as a `.completed` whose message carries a
    /// `.failed` stop reason. This keeps the agent loop free of error handling.
    enum AssistantEvent: Sendable, Equatable {
        /// A chunk of assistant text, streamed as it is produced.
        case delta(String)

        /// The terminal event: the finished assistant message.
        case completed(AssistantMessage)
    }
}
