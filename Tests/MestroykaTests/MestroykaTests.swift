import Testing
@testable import Mestroyka

@Suite("Mestroyka")
struct MestroykaTests {
    @Test("package exposes a version")
    func version() {
        #expect(!Mestroyka.version.isEmpty)
    }
}
