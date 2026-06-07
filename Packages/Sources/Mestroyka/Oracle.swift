/// The model seam: something that turns a transcript into a streamed assistant turn.
///
/// Named for what it is. The agent drives a stochastic, fallible oracle in a loop
/// (the ReAct recurrence, Yao et al. 2022; the decision cycle of Soar, Laird et
/// al. 1987). Reliability is built on top of unreliability (von Neumann 1956): an
/// oracle **never throws**. Every failure, network or model or runtime, is encoded
/// as data in the stream, a terminal `.completed` whose message carries a
/// `.failed` stop reason. This keeps the agent loop free of error handling.
///
/// A concrete oracle (an MLX-local model, later a cloud model) is just one
/// conformer; tests substitute ``Mestroyka/EchoProvider``.
public protocol Oracle: Sendable {
    /// Streams the assistant's reply to the given transcript.
    /// - Parameter messages: The conversation so far (the agent's working memory).
    /// - Returns: A stream that ends with exactly one `.completed` event.
    func stream(_ messages: [Mestroyka.Message]) -> AsyncStream<Mestroyka.AssistantEvent>
}
