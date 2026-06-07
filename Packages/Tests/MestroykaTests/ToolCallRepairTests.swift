@testable import Mestroyka
import Testing

@Suite("tool-call-repair (noisy-channel decode + allowlist codebook)")
struct ToolCallRepairTests {
    @Test("plain prose yields no calls")
    func plainProse() {
        let calls = Mestroyka.ToolCallRepair.repair(
            text: "I will check the weather for you.",
            allowed: ["weather"],
        )
        #expect(calls.isEmpty)
    }

    @Test("a leaked bracket call is recovered")
    func recoversBracketCall() {
        let calls = Mestroyka.ToolCallRepair.repair(
            text: "Sure. [tool:weather] {\"city\":\"Zagreb\"}",
            allowed: ["weather"],
        )
        #expect(calls.count == 1)
        #expect(calls.first?.name == "weather")
        #expect(calls.first?.argumentsJSON == "{\"city\":\"Zagreb\"}")
    }

    @Test("soundness: a name outside the allowlist is never promoted")
    func allowlistGate() {
        let leaked = "[tool:rm_rf] {\"path\":\"/\"}"
        #expect(Mestroyka.ToolCallRepair.repair(text: leaked, allowed: ["weather"]).isEmpty)
        #expect(Mestroyka.ToolCallRepair.repair(text: leaked, allowed: []).isEmpty)
    }

    @Test("braces inside string values do not end the object")
    func bracesInStrings() {
        let calls = Mestroyka.ToolCallRepair.repair(
            text: "[tool:echo] {\"text\":\"a}b{c\"}",
            allowed: ["echo"],
        )
        #expect(calls.count == 1)
        #expect(calls.first?.argumentsJSON == "{\"text\":\"a}b{c\"}")
    }

    @Test("two leaked calls are both recovered, in order")
    func twoCalls() {
        let calls = Mestroyka.ToolCallRepair.repair(
            text: "[tool:a] {\"x\":1} then [tool:b] {\"y\":2}",
            allowed: ["a", "b"],
        )
        #expect(calls.map(\.name) == ["a", "b"])
    }

    @Test("an unbalanced object is treated as noise, not a call")
    func unbalancedIsNoise() {
        let calls = Mestroyka.ToolCallRepair.repair(
            text: "[tool:weather] {\"city\":\"Zagreb\"",
            allowed: ["weather"],
        )
        #expect(calls.isEmpty)
    }
}
