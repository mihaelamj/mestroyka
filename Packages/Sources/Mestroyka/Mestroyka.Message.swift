public extension Mestroyka {
    /// A single message in the conversation transcript the agent maintains.
    ///
    /// The transcript is the agent's working memory. For now it holds only user
    /// turns and assistant turns; tool-result messages join when tool dispatch
    /// lands.
    enum Message: Sendable, Equatable {
        /// Text from the user.
        case user(String)

        /// A completed assistant turn.
        case assistant(AssistantMessage)
    }
}
