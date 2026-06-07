import ArgumentParser
import Mestroyka

struct MestroykaCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mestroyka",
        abstract: "A private, on-device AI agent for Apple platforms.",
        version: Mestroyka.version,
    )

    func run() throws {
        print("mestroyka \(Mestroyka.version) — scaffold. The agent loop is not wired yet.")
    }
}

MestroykaCommand.main()
