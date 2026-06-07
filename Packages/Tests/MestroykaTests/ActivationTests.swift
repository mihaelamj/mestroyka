import Foundation
@testable import Mestroyka
import Testing

@Suite("ACT-R base-level activation (Anderson & Schooler 1991)")
struct ActivationTests {
    @Test("no uses yields nil")
    func emptyIsNil() {
        #expect(Mestroyka.Activation.baseLevel(agesInSeconds: []) == nil)
        #expect(Mestroyka.Activation.baseLevel(agesInSeconds: [0, -3]) == nil)
    }

    @Test("a single use of unit age has activation zero")
    func singleUnitUse() {
        let activation = Mestroyka.Activation.baseLevel(agesInSeconds: [1.0])
        #expect(activation != nil)
        if let activation {
            #expect(abs(activation) < 1e-12)
        }
    }

    @Test("frequency raises activation: more uses score higher")
    func frequencyRaisesActivation() throws {
        let once = try #require(Mestroyka.Activation.baseLevel(agesInSeconds: [2.0]))
        let twice = try #require(Mestroyka.Activation.baseLevel(agesInSeconds: [2.0, 2.0]))
        #expect(twice > once)
    }

    @Test("recency raises activation: a more recent use scores higher")
    func recencyRaisesActivation() throws {
        let recent = try #require(Mestroyka.Activation.baseLevel(agesInSeconds: [1.0]))
        let stale = try #require(Mestroyka.Activation.baseLevel(agesInSeconds: [9.0]))
        #expect(recent > stale)
    }

    @Test("non-positive ages are ignored, not fatal")
    func ignoresNonPositiveAges() throws {
        let mixed = try #require(Mestroyka.Activation.baseLevel(agesInSeconds: [0.0, -1.0, 1.0]))
        let clean = try #require(Mestroyka.Activation.baseLevel(agesInSeconds: [1.0]))
        #expect(abs(mixed - clean) < 1e-12)
    }

    @Test("the Date convenience matches the age form")
    func dateConvenienceMatchesAges() throws {
        let now = Date(timeIntervalSinceReferenceDate: 1000)
        let uses = [now.addingTimeInterval(-1), now.addingTimeInterval(-4)]
        let viaDates = try #require(Mestroyka.Activation.baseLevel(useTimes: uses, now: now))
        let viaAges = try #require(Mestroyka.Activation.baseLevel(agesInSeconds: [1.0, 4.0]))
        #expect(abs(viaDates - viaAges) < 1e-12)
    }
}
