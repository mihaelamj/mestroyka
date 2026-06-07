import Foundation

public extension Mestroyka {
    /// Persistent memory outside the context window: remember facts, recall the
    /// relevant ones, reinforce what is used.
    ///
    /// Retrieval ranks each candidate by the sum of three min-max-normalized
    /// components, exactly the scheme of Generative Agents (Park et al. 2023):
    ///   - **recency + frequency**, via ACT-R base-level activation
    ///     (``Activation``; Anderson & Schooler 1991),
    ///   - **importance**, the item's salience weight,
    ///   - **relevance**, lexical overlap with the query (a stand-in for embedding
    ///     cosine until an on-device embedding model lands).
    ///
    /// Recalling an item appends a use to it, so frequently-recalled memories grow
    /// more accessible over time (retrieval-as-reinforcement; the consolidation of
    /// McClelland et al. 1995). This in-memory store will sit behind the same
    /// interface as the eventual SQLite + vector implementation.
    actor MemoryStore {
        private var itemsByID: [String: MemoryItem] = [:]
        private var counter = 0

        public init() {}

        /// Stores a fact and returns its identifier.
        /// - Parameters:
        ///   - text: The fact to remember.
        ///   - importance: Salience in `0...1`.
        ///   - time: When the fact was learned.
        @discardableResult
        public func remember(_ text: String, importance: Double = 0.5, at time: Date) -> String {
            counter += 1
            let id = "mem-\(counter)"
            itemsByID[id] = MemoryItem(id: id, text: text, importance: importance, uses: [time])
            return id
        }

        /// Returns the most relevant memories for `query`, and reinforces them.
        /// - Parameters:
        ///   - query: The retrieval cue.
        ///   - now: The reference instant for recency.
        ///   - limit: Maximum results.
        ///   - decay: The ACT-R decay rate.
        /// - Returns: The top items by combined score, highest first. The returned
        ///   copies reflect use history *before* this retrieval is recorded.
        public func recall(
            _ query: String,
            now: Date,
            limit: Int = 5,
            decay: Double = Activation.defaultDecay,
        ) -> [MemoryItem] {
            let ranked = Self.rank(Array(itemsByID.values), query: query, now: now, decay: decay)
            let top = Array(ranked.prefix(max(0, limit)))
            for item in top {
                itemsByID[item.id]?.uses.append(now)
            }
            return top
        }

        /// Pure ranking: combined, min-max-normalized recency/importance/relevance.
        static func rank(_ items: [MemoryItem], query: String, now: Date, decay: Double) -> [MemoryItem] {
            guard !items.isEmpty else { return [] }
            let floor = -Double.greatestFiniteMagnitude
            let activations = items.map { item in
                Activation.baseLevel(useTimes: item.uses, now: now, decay: decay) ?? floor
            }
            let importances = items.map(\.importance)
            let relevances = items.map { relevance(of: $0.text, to: query) }
            let normalizedActivation = minMaxNormalize(activations)
            let normalizedImportance = minMaxNormalize(importances)
            let normalizedRelevance = minMaxNormalize(relevances)
            let scored = items.indices.map { index -> (MemoryItem, Double) in
                let score = normalizedActivation[index] + normalizedImportance[index] + normalizedRelevance[index]
                return (items[index], score)
            }
            return scored.sorted { $0.1 > $1.1 }.map(\.0)
        }

        /// Lexical relevance: fraction of query terms present in `text`.
        static func relevance(of text: String, to query: String) -> Double {
            let queryTerms = terms(query)
            guard !queryTerms.isEmpty else { return 0 }
            let textTerms = terms(text)
            return Double(queryTerms.intersection(textTerms).count) / Double(queryTerms.count)
        }

        private static func terms(_ string: String) -> Set<String> {
            Set(string.lowercased().split { !$0.isLetter && !$0.isNumber }.map(String.init))
        }

        /// Scales values to `0...1`; returns all-zero when every value is equal.
        private static func minMaxNormalize(_ values: [Double]) -> [Double] {
            guard let lowest = values.min(), let highest = values.max() else { return values }
            let span = highest - lowest
            guard span > 1e-12 else { return values.map { _ in 0 } }
            return values.map { ($0 - lowest) / span }
        }
    }
}
