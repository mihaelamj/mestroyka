/// Decides whether an irreversible tool call may proceed.
///
/// The model's output is not a trusted principal: anything it says may be an
/// injected instruction wearing the costume of a thought. Authority therefore
/// rests in the host, not the model. An approver is the declassifier in an
/// information-flow sense (Denning 1976) and the human-in-the-loop of the
/// untrusted-prover / Byzantine stance (Lamport et al. 1982): tainted model
/// output cannot reach an irreversible action without passing this gate.
public protocol Approver: Sendable {
    /// Returns whether the given irreversible call may run.
    func approve(_ call: Mestroyka.ToolCall) async -> Bool
}

public extension Mestroyka {
    /// An approver that permits every call. The default when no gate is wired,
    /// suitable for a trusted single operator running only read-only tools.
    struct AllowAllApprover: Approver {
        public init() {}

        public func approve(_: ToolCall) async -> Bool {
            true
        }
    }
}
