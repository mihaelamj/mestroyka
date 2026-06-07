import Foundation
@testable import Mestroyka
import Testing

@Suite("declarative memory: retrieval and reinforcement")
struct MemoryStoreTests {
    private func item(_ id: String, _ text: String, importance: Double, uses: [Date]) -> Mestroyka.MemoryItem {
        .init(id: id, text: text, importance: importance, uses: uses)
    }

    @Test("an empty store recalls nothing")
    func emptyRecall() async {
        let store = Mestroyka.MemoryStore()
        let result = await store.recall("anything", now: Date())
        #expect(result.isEmpty)
    }

    @Test("relevance ranks a query-matching memory above an unrelated one")
    func relevanceRanks() {
        let now = Date(timeIntervalSinceReferenceDate: 1000)
        let used = [now.addingTimeInterval(-10)]
        let items = [
            item("a", "the weather in Zagreb is nice", importance: 0.5, uses: used),
            item("b", "i had pizza for lunch", importance: 0.5, uses: used),
        ]
        let ranked = Mestroyka.MemoryStore.rank(items, query: "weather", now: now, decay: 0.5)
        #expect(ranked.first?.id == "a")
    }

    @Test("recency ranks a recently-used memory above a stale one")
    func recencyRanks() {
        let now = Date(timeIntervalSinceReferenceDate: 1000)
        let items = [
            item("recent", "alpha", importance: 0.5, uses: [now.addingTimeInterval(-1)]),
            item("stale", "alpha", importance: 0.5, uses: [now.addingTimeInterval(-10000)]),
        ]
        let ranked = Mestroyka.MemoryStore.rank(items, query: "alpha", now: now, decay: 0.5)
        #expect(ranked.first?.id == "recent")
    }

    @Test("importance breaks ties when recency and relevance match")
    func importanceRanks() {
        let now = Date(timeIntervalSinceReferenceDate: 1000)
        let used = [now.addingTimeInterval(-5)]
        let items = [
            item("low", "alpha", importance: 0.1, uses: used),
            item("high", "alpha", importance: 0.9, uses: used),
        ]
        let ranked = Mestroyka.MemoryStore.rank(items, query: "alpha", now: now, decay: 0.5)
        #expect(ranked.first?.id == "high")
    }

    @Test("retrieval reinforces: a recalled memory accrues a use")
    func retrievalReinforces() async {
        let store = Mestroyka.MemoryStore()
        let t0 = Date(timeIntervalSinceReferenceDate: 0)
        await store.remember("alpha", at: t0)
        _ = await store.recall("alpha", now: t0.addingTimeInterval(1))
        let second = await store.recall("alpha", now: t0.addingTimeInterval(2))
        // The first recall recorded a use, so by the second recall there are two.
        #expect(second.first?.uses.count == 2)
    }
}
