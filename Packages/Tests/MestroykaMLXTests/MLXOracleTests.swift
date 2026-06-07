import Mestroyka
@testable import MestroykaMLX
import MLXLMCommon
import Testing

@Suite("MLX oracle: transcript-to-chat mapping")
struct MLXOracleTests {
    @Test("user, assistant, and tool-result map to the model's chat roles")
    func mapsRolesAndContent() {
        let chat = MLXOracle.chatMessages(from: [
            .user("hi"),
            .assistant(.init(text: "hello", stopReason: .endTurn)),
            .toolResult(name: "weather", content: "sunny"),
        ])
        #expect(chat.map(\.role) == [.user, .assistant, .tool])
        #expect(chat.map(\.content) == ["hi", "hello", "[weather] sunny"])
    }

    @Test("an empty transcript maps to no chat messages")
    func emptyTranscript() {
        #expect(MLXOracle.chatMessages(from: []).isEmpty)
    }
}
