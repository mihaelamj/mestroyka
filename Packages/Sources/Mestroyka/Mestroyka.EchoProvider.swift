public extension Mestroyka {
    /// A deterministic ``Oracle`` that echoes the last user message back.
    ///
    /// Not a toy: it is the substitutable fake the agent loop is tested against
    /// (dependency injection, so behaviour can be verified without a model), and
    /// it doubles as a no-model smoke mode.
    struct EchoProvider: Oracle {
        private let prefix: String

        /// Creates an echo provider.
        /// - Parameter prefix: Text prepended to the echoed user message.
        public init(prefix: String = "echo: ") {
            self.prefix = prefix
        }

        public func stream(_ messages: [Message]) -> AsyncStream<AssistantEvent> {
            let lastUserText = messages.reversed().compactMap { message -> String? in
                guard case let .user(text) = message else { return nil }
                return text
            }.first ?? ""
            let reply = prefix + lastUserText
            return AsyncStream { continuation in
                continuation.yield(.delta(reply))
                continuation.yield(.completed(AssistantMessage(text: reply, stopReason: .endTurn)))
                continuation.finish()
            }
        }
    }
}
