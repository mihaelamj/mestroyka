import Foundation
@testable import Mestroyka
import Testing

private struct GuardedTool: Tool {
    let name: String
    let isIrreversible: Bool
    func execute(argumentsJSON _: String) async -> Mestroyka.ToolResult {
        Mestroyka.ToolResult(content: "ran")
    }
}

private struct DenyAllApprover: Approver {
    func approve(_: Mestroyka.ToolCall) async -> Bool {
        false
    }
}

private final class ScriptedOnce: Oracle, @unchecked Sendable {
    private let first: Mestroyka.AssistantMessage
    private let lock = NSLock()
    private var done = false

    init(_ first: Mestroyka.AssistantMessage) {
        self.first = first
    }

    func stream(_: [Mestroyka.Message]) -> AsyncStream<Mestroyka.AssistantEvent> {
        lock.lock()
        let turn = done ? Mestroyka.AssistantMessage(text: "stop", stopReason: .endTurn) : first
        done = true
        lock.unlock()
        return AsyncStream { continuation in
            continuation.yield(.completed(turn))
            continuation.finish()
        }
    }
}

private func callTo(_ name: String) -> Mestroyka.AssistantMessage {
    .init(text: "", toolCalls: [.init(id: name, name: name, argumentsJSON: "{}")], stopReason: .toolUse)
}

@Suite("trust: approval gate on irreversible tools")
struct TrustTests {
    @Test("a reversible tool runs even when the approver denies everything")
    func reversibleIsNotGated() async {
        let loop = Mestroyka.AgentLoop(
            oracle: ScriptedOnce(callTo("read")),
            tools: [GuardedTool(name: "read", isIrreversible: false)],
            approver: DenyAllApprover(),
        )
        let result = await loop.run([.user("go")])
        #expect(result.contains(.toolResult(name: "read", content: "ran")))
    }

    @Test("an irreversible tool is blocked when the approver denies it")
    func irreversibleDenied() async {
        let loop = Mestroyka.AgentLoop(
            oracle: ScriptedOnce(callTo("send")),
            tools: [GuardedTool(name: "send", isIrreversible: true)],
            approver: DenyAllApprover(),
        )
        let result = await loop.run([.user("go")])
        #expect(result.contains(.toolResult(name: "send", content: "Denied by the approval policy: send")))
        #expect(!result.contains(.toolResult(name: "send", content: "ran")))
    }

    @Test("an irreversible tool runs when approved (the default allow-all)")
    func irreversibleApproved() async {
        let loop = Mestroyka.AgentLoop(
            oracle: ScriptedOnce(callTo("send")),
            tools: [GuardedTool(name: "send", isIrreversible: true)],
        )
        let result = await loop.run([.user("go")])
        #expect(result.contains(.toolResult(name: "send", content: "ran")))
    }
}
