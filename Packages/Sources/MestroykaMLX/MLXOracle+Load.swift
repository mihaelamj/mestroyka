import Foundation
import HuggingFace
import MLXHuggingFace
import MLXLMCommon
import Tokenizers

public extension MLXOracle {
    /// Loads a model from the Hugging Face hub by repo id and returns a ready
    /// ``MLXOracle``. The weights are downloaded on first use and cached under
    /// `~/.cache/huggingface/`.
    ///
    /// - Parameters:
    ///   - id: A Hugging Face repo id, e.g. `mlx-community/Qwen2.5-0.5B-Instruct-4bit`.
    ///   - instructions: Optional system instructions.
    ///   - parameters: Generation parameters.
    static func load(
        id: String,
        instructions: String? = nil,
        parameters: GenerateParameters = GenerateParameters(),
    ) async throws -> MLXOracle {
        let container = try await loadModelContainer(
            from: #hubDownloader(),
            using: #huggingFaceTokenizerLoader(),
            id: id,
        )
        return MLXOracle(container: container, instructions: instructions, parameters: parameters)
    }
}
