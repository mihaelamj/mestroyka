import ArgumentParser
import Foundation
import Mestroyka
import MestroykaMLX

@main
@available(macOS 13, *)
struct MestroykaCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mestroyka",
        abstract: "A private, on-device AI agent for Apple platforms.",
        version: Mestroyka.version,
    )

    @Option(name: .shortAndLong, help: "Hugging Face model repo id (e.g. mlx-community/Qwen2.5-0.5B-Instruct-4bit).")
    var model: String?

    @Flag(help: "Run on the CPU instead of the GPU (use if the Metal library is unavailable).")
    var cpu = false

    @Argument(parsing: .remaining, help: "The prompt to send to the model.")
    var prompt: [String] = []

    func run() async throws {
        if cpu {
            MLXOracle.useCPUDevice()
        }
        guard let model else {
            print("mestroyka \(Mestroyka.version). Pass --model <hf-repo> and a prompt to run a local model.")
            return
        }
        let promptText = prompt.joined(separator: " ")
        guard !promptText.isEmpty else {
            throw ValidationError("Provide a prompt, e.g. mestroyka --model \(model) \"hello\"")
        }
        log("Loading \(model) (downloads on first run, cached under ~/.cache/huggingface)...")
        let oracle = try await MLXOracle.load(id: model)
        log("Thinking...")
        let loop = Mestroyka.AgentLoop(oracle: oracle)
        let transcript = await loop.run([.user(promptText)])
        guard case let .assistant(assistant) = transcript.last else { return }
        switch assistant.stopReason {
        case .endTurn, .toolUse:
            print(assistant.text)
        case let .failed(reason, recovery):
            log("Failed: \(reason)\n\(recovery)")
        }
    }

    private func log(_ message: String) {
        FileHandle.standardError.write(Data((message + "\n").utf8))
    }
}
