import Foundation
@testable import Mestroyka
import Testing

/// An oracle that replays a fixed script of turns, clamping to the last one so a
/// trailing tool-using turn repeats forever (useful for the step-bound test).
private final class ScriptedOracle: Oracle, @unchecked Sendable {
    private let script: [Mestroyka.AssistantMessage]
    private let lock = NSLock()
    private var index = 0

    init(_ script: [Mestroyka.AssistantMessage]) {
        self.script = script
    }

    func stream(_: [Mestroyka.Message]) -> AsyncStream<Mestroyka.AssistantEvent> {
        lock.lock()
        let turn = script.isEmpty
            ? Mestroyka.AssistantMessage(text: "", stopReason: .endTurn)
            : script[min(index, script.count - 1)]
        index += 1
        lock.unlock()
        return AsyncStream { continuation in
            continuation.yield(.completed(turn))
            continuation.finish()
        }
    }
}

private struct FakeTool: Tool {
    let name: String
    let reply: String

    func execute(argumentsJSON _: String) async -> Mestroyka.ToolResult {
        Mestroyka.ToolResult(content: reply)
    }
}

private func call(_ name: String) -> Mestroyka.ToolCall {
    Mestroyka.ToolCall(id: name, name: name, argumentsJSON: "{}")
}

@Suite("the decision cycle with tools")
struct AgentLoopToolTests {
    @Test("a requested tool runs and its result feeds the next turn")
    func dispatchesAndContinues() async {
        let oracle = ScriptedOracle([
            .init(text: "", toolCalls: [call("greet")], stopReason: .toolUse),
            .init(text: "done", stopReason: .endTurn),
        ])
        let loop = Mestroyka.AgentLoop(oracle: oracle, tools: [FakeTool(name: "greet", reply: "hello")])
        let result = await loop.run([.user("hi")])
        #expect(result.contains(.toolResult(name: "greet", content: "hello")))
        #expect(result.last == .assistant(.init(text: "done", stopReason: .endTurn)))
    }

    @Test("an unregistered tool yields an error result, not a crash")
    func unknownTool() async {
        let oracle = ScriptedOracle([
            .init(text: "", toolCalls: [call("missing")], stopReason: .toolUse),
            .init(text: "ok", stopReason: .endTurn),
        ])
        let loop = Mestroyka.AgentLoop(oracle: oracle)
        let result = await loop.run([.user("hi")])
        #expect(result.contains(.toolResult(name: "missing", content: "Unknown tool: missing")))
    }

    @Test("a tool call leaked as text is recovered and run")
    func recoversLeakedCall() async {
        let oracle = ScriptedOracle([
            .init(text: "[tool:greet] {}", stopReason: .endTurn),
            .init(text: "done", stopReason: .endTurn),
        ])
        let loop = Mestroyka.AgentLoop(oracle: oracle, tools: [FakeTool(name: "greet", reply: "hello")])
        let result = await loop.run([.user("hi")])
        #expect(result.contains(.toolResult(name: "greet", content: "hello")))
    }

    @Test("the step bound terminates an oracle that never stops asking for tools")
    func stepBoundTerminates() async {
        let oracle = ScriptedOracle([
            .init(text: "", toolCalls: [call("greet")], stopReason: .toolUse),
        ])
        let loop = Mestroyka.AgentLoop(
            oracle: oracle,
            tools: [FakeTool(name: "greet", reply: "hello")],
            maxSteps: 3,
        )
        let result = await loop.run([.user("hi")])
        guard case let .assistant(last) = result.last, case .failed = last.stopReason else {
            Issue.record("expected a terminal .failed assistant turn at the step bound")
            return
        }
        // 3 tool-using turns, each: assistant + toolResult, then the step-limit turn.
        #expect(result.count(where: { if case .toolResult = $0 { true } else { false } }) == 3)
    }
}
