import Foundation

public extension Mestroyka {
    /// One remembered fact: its text, a salience weight, and when it has been used.
    ///
    /// The use history is what makes the memory adaptive: it drives the ACT-R
    /// activation (``Activation``) that decides accessibility, and each retrieval
    /// appends to it (retrieval-as-reinforcement).
    struct MemoryItem: Sendable, Equatable {
        /// Stable identifier assigned by the store.
        public let id: String

        /// The remembered text.
        public var text: String

        /// Salience in `0...1` (the "importance" of Generative Agents, Park 2023).
        public var importance: Double

        /// Timestamps of every use (creation and each later retrieval).
        public var uses: [Date]

        /// Creates a memory item.
        public init(id: String, text: String, importance: Double, uses: [Date]) {
            self.id = id
            self.text = text
            self.importance = min(1, max(0, importance))
            self.uses = uses
        }
    }
}
