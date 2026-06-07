public extension Mestroyka {
    /// Why an assistant turn stopped producing output.
    ///
    /// Failures are values, not thrown errors: a provider that cannot answer
    /// returns a finished message carrying `.failed`, so the agent loop stays
    /// branch-free. Each failure carries both a human-readable reason and an
    /// actionable recovery.
    enum StopReason: Sendable, Equatable {
        /// The assistant finished its turn normally and requested no further action.
        case endTurn

        /// The assistant paused to run tools; the loop should dispatch them and continue.
        case toolUse

        /// The provider failed to produce a turn.
        /// - Parameters:
        ///   - reason: What went wrong, in plain language.
        ///   - recovery: A concrete next step the caller can take.
        case failed(reason: String, recovery: String)
    }
}
