import Foundation
import Mestroyka
import MLXLMCommon

/// An ``Oracle`` backed by a local MLX language model on Apple silicon.
///
/// The model is injected as a loaded `ModelContainer`, so this type stays a pure
/// transcript-to-generation adapter (loading a model is the caller's concern and
/// cannot be unit-tested anyway). It maps mestroyka's transcript to the model's
/// chat format, runs one generation per call, and streams the result as
/// ``Mestroyka/AssistantEvent`` values. It never throws: a generation error is
/// delivered as a `.completed` whose message carries a `.failed` stop reason.
public struct MLXOracle: Oracle {
    private let container: ModelContainer
    private let instructions: String?
    private let parameters: GenerateParameters

    /// Creates an MLX-backed oracle.
    /// - Parameters:
    ///   - container: A loaded MLX model container.
    ///   - instructions: Optional system instructions.
    ///   - parameters: Generation parameters (temperature, token limits, ...).
    public init(
        container: ModelContainer,
        instructions: String? = nil,
        parameters: GenerateParameters = GenerateParameters(),
    ) {
        self.container = container
        self.instructions = instructions
        self.parameters = parameters
    }

    public func stream(_ messages: [Mestroyka.Message]) -> AsyncStream<Mestroyka.AssistantEvent> {
        let container = container
        let instructions = instructions
        let parameters = parameters
        return AsyncStream { continuation in
            let task = Task {
                let chat = Self.chatMessages(from: messages)
                guard let last = chat.last else {
                    continuation.yield(.completed(Mestroyka.AssistantMessage(
                        text: "",
                        stopReason: .failed(
                            reason: "The transcript was empty.",
                            recovery: "Provide at least one message before streaming.",
                        ),
                    )))
                    continuation.finish()
                    return
                }
                let session = ChatSession(
                    container,
                    instructions: instructions,
                    history: Array(chat.dropLast()),
                    generateParameters: parameters,
                )
                var accumulated = ""
                do {
                    for try await chunk in session.streamResponse(to: last.content, role: last.role, images: [], videos: []) {
                        accumulated += chunk
                        continuation.yield(.delta(chunk))
                    }
                    continuation.yield(.completed(Mestroyka.AssistantMessage(text: accumulated, stopReason: .endTurn)))
                } catch {
                    continuation.yield(.completed(Mestroyka.AssistantMessage(
                        text: accumulated,
                        stopReason: .failed(
                            reason: "Generation failed: \(error.localizedDescription)",
                            recovery: "Verify the model container and the inputs, then retry.",
                        ),
                    )))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// Maps the agent transcript to the model's chat format. Pure and testable.
    static func chatMessages(from messages: [Mestroyka.Message]) -> [Chat.Message] {
        messages.map { message in
            switch message {
            case let .user(text):
                Chat.Message.user(text)
            case let .assistant(assistant):
                Chat.Message.assistant(assistant.text)
            case let .toolResult(name, content):
                Chat.Message.tool("[\(name)] \(content)")
            }
        }
    }
}
