@testable import Mestroyka
import Testing

@Suite("token budgeting and compaction routing (online paging)")
struct TokenBudgetTests {
    @Test("a small transcript fits")
    func smallFits() {
        let messages: [Mestroyka.Message] = [.user("hello")]
        #expect(Mestroyka.TokenBudget.route(messages: messages, budget: 4096) == .fits)
    }

    @Test("estimate counts prose at four characters per token plus overhead")
    func estimateShape() {
        // 400 characters of prose: 100 token-equivalents + 12 overhead.
        let text = String(repeating: "a", count: 400)
        #expect(Mestroyka.TokenBudget.estimateTokens(.user(text)) == 112)
    }

    @Test("over budget with nothing reducible: compact")
    func compactWhenNothingReducible() {
        let messages: [Mestroyka.Message] = [.user(String(repeating: "a", count: 400))]
        // estimate 112, safety -> 124, budget 100 -> overflow 24, no reducible tool tokens.
        #expect(Mestroyka.TokenBudget.route(messages: messages, budget: 100) == .compact)
    }

    @Test("over budget with comfortably-large reducible tool output: truncate")
    func truncateWhenReducibleIsLarge() {
        let messages: [Mestroyka.Message] = [.user(String(repeating: "a", count: 400))]
        #expect(
            Mestroyka.TokenBudget.route(messages: messages, budget: 100, reducibleToolTokens: 1000)
                == .truncateToolResults,
        )
    }

    @Test("over budget with some but not comfortable reducible: compact then truncate")
    func compactThenTruncateWhenReducibleIsSmall() {
        let messages: [Mestroyka.Message] = [.user(String(repeating: "a", count: 400))]
        #expect(
            Mestroyka.TokenBudget.route(messages: messages, budget: 100, reducibleToolTokens: 10)
                == .compactThenTruncate,
        )
    }
}
