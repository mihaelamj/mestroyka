@testable import Mestroyka
import Testing

@Suite("Mestroyka")
struct MestroykaTests {
    @Test("package exposes a version")
    func version() {
        #expect(!Mestroyka.version.isEmpty)
    }
}
