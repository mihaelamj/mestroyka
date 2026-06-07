import Foundation

public extension Mestroyka {
    /// Memory strength as a function of how a memory has been used.
    ///
    /// This is the ACT-R base-level activation, the rational analysis of memory of
    /// Anderson & Schooler ("Reflections of the Environment in Memory",
    /// Psychological Science, 1991): a memory's accessibility tracks its *need
    /// probability*, and need probability is predicted by the frequency and
    /// recency of past use. It is the principled, environment-optimal answer to
    /// "which memories should we keep accessible", unifying the recency of LRU and
    /// the frequency of LFU (Sleator & Tarjan 1985) into one quantity. mestroyka
    /// uses it to rank and promote memories ("dreaming", in the sense of
    /// McClelland et al. 1995) instead of a hand-tuned heuristic.
    ///
    ///     B = ln( Σⱼ tⱼ^(−d) )
    ///
    /// where `tⱼ` is the age of the j-th use and `d` is the decay rate.
    enum Activation {
        /// The classic ACT-R decay rate.
        static let defaultDecay = 0.5

        /// Base-level activation `B = ln(Σ tⱼ^(−d))` over the ages of past uses.
        ///
        /// More uses raise activation (frequency); more recent uses raise it more
        /// (recency). With a single use of age 1, `B = 0`.
        ///
        /// - Parameters:
        ///   - agesInSeconds: Age of each past use, in seconds. Non-positive ages
        ///     (a use "now" or in the future) are ignored, since `tⱼ^(−d)` is only
        ///     defined for `tⱼ > 0`.
        ///   - decay: The decay rate `d`. Defaults to the ACT-R value `0.5`.
        /// - Returns: The activation, or `nil` if there are no usable past uses.
        static func baseLevel(agesInSeconds: [Double], decay: Double = defaultDecay) -> Double? {
            let positiveAges = agesInSeconds.filter { $0 > 0 }
            guard !positiveAges.isEmpty else { return nil }
            let sum = positiveAges.reduce(0.0) { partial, age in
                partial + pow(age, -decay)
            }
            return log(sum)
        }

        /// Convenience: base-level activation from absolute use times relative to `now`.
        /// - Parameters:
        ///   - useTimes: When the memory was used.
        ///   - now: The reference instant.
        ///   - decay: The decay rate `d`.
        /// - Returns: The activation, or `nil` if no use is strictly before `now`.
        static func baseLevel(useTimes: [Date], now: Date, decay: Double = defaultDecay) -> Double? {
            let ages = useTimes.map { now.timeIntervalSince($0) }
            return baseLevel(agesInSeconds: ages, decay: decay)
        }
    }
}
