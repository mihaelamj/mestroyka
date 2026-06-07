public extension Mestroyka {
    /// Fit the transcript into the model's finite context window.
    ///
    /// The window is a bounded store whose pressure rises monotonically as the
    /// loop runs; deciding what to keep, drop, or compress, online and with no
    /// knowledge of the future, is the **virtual-memory paging** problem. Belady's
    /// MIN (1966) is the optimum and is unreachable (it needs clairvoyance);
    /// Denning's working set (1968) is the practical, locality-based answer; and
    /// Sleator & Tarjan (1985) formalize that an online policy like ours can only
    /// be measured competitively against that unreachable optimum. Summarizing old
    /// turns rather than dropping them is lossy source coding under a rate budget
    /// (Shannon's rate-distortion, 1959).
    ///
    /// The token estimate is deliberately crude and conservative: a cheap estimate
    /// computed *before* the call beats an exact count that arrives after a refusal.
    enum TokenBudget {
        /// Characters per token for prose. Crude on purpose.
        static let proseCharactersPerToken = 4.0
        /// Flat per-message structural overhead, in tokens.
        static let perMessageOverheadTokens = 12
        /// Multiplier applied to the raw estimate, biasing toward over-counting.
        static let safetyMargin = 1.1

        /// A conservative token estimate for one message.
        static func estimateTokens(_ message: Message) -> Int {
            let text: String = switch message {
            case let .user(value):
                value
            case let .assistant(assistant):
                assistant.text
            }
            let textTokens = (Double(text.count) / proseCharactersPerToken).rounded(.up)
            return Int(textTokens) + perMessageOverheadTokens
        }

        /// A conservative token estimate for a transcript.
        static func estimateTokens(_ messages: [Message]) -> Int {
            messages.reduce(0) { running, message in
                running + estimateTokens(message)
            }
        }

        /// What to do to make the transcript fit the budget.
        enum Route: Equatable {
            /// The transcript already fits; send as-is.
            case fits
            /// Drop bulky, stale tool output; that alone recovers enough room.
            case truncateToolResults
            /// Summarize older turns (lossy), because there is nothing cheaper to drop.
            case compact
            /// Summarize and then trim tool output.
            case compactThenTruncate
        }

        /// Choose a route to fit `messages` within `budget` tokens.
        ///
        /// Prefers the cheapest sacrifice: dropping stale tool output (bulky and
        /// low-value) over summarizing the conversation (meaningful and lossy), and
        /// only when the recoverable tool tokens comfortably exceed the overflow.
        ///
        /// - Parameters:
        ///   - messages: The transcript to fit.
        ///   - budget: The token budget (the window, minus any reserve).
        ///   - reducibleToolTokens: Tokens recoverable by truncating tool output.
        /// - Returns: The chosen route.
        static func route(messages: [Message], budget: Int, reducibleToolTokens: Int = 0) -> Route {
            let estimated = Int((Double(estimateTokens(messages)) * safetyMargin).rounded(.up))
            guard estimated > budget else { return .fits }
            let overflow = estimated - budget
            let comfortableMargin = max(Double(overflow) * 1.5, Double(overflow) + 512)
            if Double(reducibleToolTokens) >= comfortableMargin { return .truncateToolResults }
            if reducibleToolTokens > 0 { return .compactThenTruncate }
            return .compact
        }
    }
}
