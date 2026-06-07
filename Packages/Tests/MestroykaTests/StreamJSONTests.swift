import Foundation
@testable import Mestroyka
import Testing

@Suite("stream-json output (iRelay agent protocol)")
struct StreamJSONTests {
    private func decode(_ line: String) -> [String: String] {
        guard
            let data = line.data(using: .utf8),
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: String]
        else {
            return [:]
        }
        return object
    }

    @Test("a message line carries type and content")
    func messageLine() {
        let decoded = decode(Mestroyka.StreamJSON.message("hello"))
        #expect(decoded["type"] == "message")
        #expect(decoded["content"] == "hello")
    }

    @Test("content with quotes and newlines is valid JSON")
    func escaping() {
        let decoded = decode(Mestroyka.StreamJSON.message("say \"hi\"\nthen bye"))
        #expect(decoded["content"] == "say \"hi\"\nthen bye")
    }

    @Test("a function_call line carries name and arguments")
    func functionCallLine() {
        let decoded = decode(Mestroyka.StreamJSON.functionCall(name: "read_file", arguments: "{\"path\":\"/x\"}"))
        #expect(decoded["type"] == "function_call")
        #expect(decoded["name"] == "read_file")
        #expect(decoded["arguments"] == "{\"path\":\"/x\"}")
    }

    // The next two tests pin the exact wire bytes (sorted keys, no spaces) that
    // iRelay's `CodexStreamParser` consumes. The same literals appear in iRelay's
    // `MestroykaWireContractTests`; keep the two in lockstep so a format change
    // here is caught on both sides of the cross-tool boundary.

    @Test("message line is exactly the sorted-key Codex shape")
    func messageExactBytes() {
        #expect(
            Mestroyka.StreamJSON.message("hello from on-device")
                == #"{"content":"hello from on-device","type":"message"}"#,
        )
    }

    @Test("function_call line is exactly the sorted-key Codex shape")
    func functionCallExactBytes() {
        // JSONSerialization escapes forward slashes as `\/` (valid JSON; a
        // conformant decoder, including iRelay's, reads `\/` back as `/`).
        #expect(
            Mestroyka.StreamJSON.functionCall(name: "read_file", arguments: #"{"path":"/etc/hosts"}"#)
                == #"{"arguments":"{\"path\":\"\/etc\/hosts\"}","name":"read_file","type":"function_call"}"#,
        )
    }

    @Test("a transcript becomes tool-call lines followed by the final message")
    func transcriptLines() {
        let transcript: [Mestroyka.Message] = [
            .user("hi"),
            .assistant(.init(
                text: "done",
                toolCalls: [.init(id: "1", name: "read_file", argumentsJSON: "{}")],
                stopReason: .endTurn,
            )),
        ]
        let lines = Mestroyka.StreamJSON.lines(for: transcript)
        #expect(lines.count == 2)
        #expect(decode(lines[0])["type"] == "function_call")
        #expect(decode(lines[1])["type"] == "message")
        #expect(decode(lines[1])["content"] == "done")
    }
}
