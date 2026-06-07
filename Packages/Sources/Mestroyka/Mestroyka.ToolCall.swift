public extension Mestroyka {
    /// A request from the oracle to run one tool.
    ///
    /// A call may arrive structured (the provider's native channel) or be
    /// recovered from leaked text by ``ToolCallRepair``; either way it reaches the
    /// loop as one of these.
    struct ToolCall: Sendable, Equatable {
        /// A stable identifier for correlating the call with its result.
        public var id: String

        /// The tool name. The loop only runs calls whose name is registered.
        public var name: String

        /// The raw JSON arguments object.
        public var argumentsJSON: String

        /// Creates a tool call.
        public init(id: String, name: String, argumentsJSON: String) {
            self.id = id
            self.name = name
            self.argumentsJSON = argumentsJSON
        }
    }
}
