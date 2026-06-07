public extension Mestroyka {
    /// The outcome of running a tool, fed back into the transcript for the oracle.
    ///
    /// A failed tool does not throw and does not stop the loop: the failure is
    /// content the oracle reads and can react to (errors as data).
    struct ToolResult: Sendable, Equatable {
        /// What the tool produced, or a description of why it failed.
        public var content: String

        /// Whether `content` describes a failure.
        public var isError: Bool

        /// Creates a tool result.
        public init(content: String, isError: Bool = false) {
            self.content = content
            self.isError = isError
        }
    }
}
