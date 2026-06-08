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

    /// The default model when none is given. A capable instruct model: the
    /// smaller 0.5B variant could not answer reliably or follow the tool-call
    /// format (it leaked raw tool syntax into the reply), so the default is a
    /// 7B that downloads on first run and is cached thereafter. Override with
    /// `--model` for a smaller/faster model.
    static let defaultModel = "mlx-community/Qwen2.5-7B-Instruct-4bit"

    @Option(name: .shortAndLong, help: "Hugging Face model repo id. Defaults to \(MestroykaCommand.defaultModel).")
    var model: String?

    @Flag(help: "Run on the CPU instead of the GPU (use if the Metal library is unavailable).")
    var cpu = false

    @Argument(parsing: .remaining, help: "The prompt to send to the model.")
    var prompt: [String] = []

    func run() async throws {
        if cpu {
            MLXOracle.useCPUDevice()
        }
        let resolvedModel = model ?? Self.defaultModel
        // The prompt comes from the argument, or from stdin when piped (the shape
        // an agent host such as iRelay uses).
        var promptText = prompt.joined(separator: " ")
        if promptText.isEmpty {
            let piped = FileHandle.standardInput.readDataToEndOfFile()
            promptText = String(data: piped, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        guard !promptText.isEmpty else {
            throw ValidationError("Provide a prompt as an argument or on stdin.")
        }
        // Read-only tools are safe to expose in a non-interactive run; the shell
        // tool is irreversible and stays out of the default set.
        let tools: [any Tool] = [Mestroyka.FileReadTool()]
        let systemPrompt = Mestroyka.SystemPrompt.build(tools: tools)
        log("Loading \(resolvedModel) (downloads on first run, cached under ~/.cache/huggingface)...")
        let oracle = try await MLXOracle.load(id: resolvedModel, instructions: systemPrompt)
        log("Thinking...")
        let loop = Mestroyka.AgentLoop(oracle: oracle, tools: tools)
        let transcript = await loop.run([.user(promptText)])
        // mestroyka is a self-contained agent: it dispatches its own tools and
        // returns the final assistant text. A host (such as iRelay's agent
        // bridge) pipes the prompt in and reads this plain text back as the
        // reply, so stdout carries only that text; status goes to stderr.
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
