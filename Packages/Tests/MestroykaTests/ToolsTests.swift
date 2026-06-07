import Foundation
@testable import Mestroyka
import Testing

@Suite("built-in tools")
struct ToolsTests {
    @Test("read_file returns the file contents")
    func readFileSucceeds() async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("mestroyka-\(UUID().uuidString).txt")
        try "alpha beta".write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }
        let result = await Mestroyka.FileReadTool().execute(argumentsJSON: "{\"path\":\"\(url.path)\"}")
        #expect(result.content == "alpha beta")
        #expect(result.isError == false)
    }

    @Test("read_file reports a missing file as an error, not a crash")
    func readFileMissing() async {
        let result = await Mestroyka.FileReadTool().execute(argumentsJSON: "{\"path\":\"/no/such/file-xyz\"}")
        #expect(result.isError)
    }

    @Test("read_file rejects malformed arguments")
    func readFileBadArgs() async {
        let result = await Mestroyka.FileReadTool().execute(argumentsJSON: "not json")
        #expect(result.isError)
    }

    @Test("shell runs a command and returns its output")
    func shellSucceeds() async {
        let result = await Mestroyka.ShellTool().execute(argumentsJSON: "{\"command\":\"printf hello\"}")
        #expect(result.content == "hello")
        #expect(result.isError == false)
    }

    @Test("shell reports a non-zero exit as an error")
    func shellFails() async {
        let result = await Mestroyka.ShellTool().execute(argumentsJSON: "{\"command\":\"exit 3\"}")
        #expect(result.isError)
    }

    @Test("shell is irreversible, so it is subject to the approval gate")
    func shellIsIrreversible() {
        #expect(Mestroyka.ShellTool().isIrreversible)
        #expect(Mestroyka.FileReadTool().isIrreversible == false)
    }
}
