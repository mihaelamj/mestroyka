@testable import Mestroyka
import Testing

@Suite("the decision cycle")
struct AgentLoopTests {
    @Test("one turn appends the oracle's reply to the transcript")
    func appendsReply() async {
        let loop = Mestroyka.AgentLoop(oracle: Mestroyka.EchoProvider(prefix: "echo: "))
        let result = await loop.run([.user("hi")])
        #expect(result.count == 2)
        #expect(result.first == .user("hi"))
        #expect(
            result.last == .assistant(.init(text: "echo: hi", stopReason: .endTurn)),
        )
    }

    @Test("the echo provider replies to the most recent user message")
    func echoesLastUser() async {
        let loop = Mestroyka.AgentLoop(oracle: Mestroyka.EchoProvider(prefix: ">> "))
        let result = await loop.run([.user("first"), .user("second")])
        #expect(result.last == .assistant(.init(text: ">> second", stopReason: .endTurn)))
    }
}
