// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Mestroyka",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "Mestroyka", targets: ["Mestroyka"]),
        .library(name: "MestroykaMLX", targets: ["MestroykaMLX"]),
        .executable(name: "mestroyka", targets: ["MestroykaCLI"]),
    ],
    dependencies: [
        // On-device LLM inference on Apple Silicon. Brings mlx-swift transitively.
        .package(url: "https://github.com/ml-explore/mlx-swift-lm", .upToNextMinor(from: "3.31.3")),
        .package(url: "https://github.com/ml-explore/mlx-swift", .upToNextMinor(from: "0.31.3")),
        // Hugging Face hub + tokenizers, used by the MLXHuggingFace macros to load
        // models by repo id. mlx-swift-lm leaves these to the consumer.
        .package(url: "https://github.com/huggingface/swift-huggingface", from: "0.9.0"),
        .package(url: "https://github.com/huggingface/swift-transformers", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        // Agent / tool plumbing (MCP) lands later:
        //   https://github.com/mihaelamj/SwiftMCPServer
    ],
    targets: [
        // ---------- Core ----------
        // Pure-Swift kernel: no MLX, no heavy deps. Fast to build and test.
        .target(
            name: "Mestroyka",
        ),
        // ---------- Apple-Silicon provider ----------
        // The MLX model seam, isolated so the heavy MLX stack never compiles into
        // the core library or its tests.
        .target(
            name: "MestroykaMLX",
            dependencies: [
                "Mestroyka",
                .product(name: "MLX", package: "mlx-swift"),
                .product(name: "MLXLLM", package: "mlx-swift-lm"),
                .product(name: "MLXLMCommon", package: "mlx-swift-lm"),
                .product(name: "MLXHuggingFace", package: "mlx-swift-lm"),
                .product(name: "HuggingFace", package: "swift-huggingface"),
                .product(name: "Tokenizers", package: "swift-transformers"),
            ],
        ),
        // ---------- CLI ----------
        .executableTarget(
            name: "MestroykaCLI",
            dependencies: [
                "Mestroyka",
                "MestroykaMLX",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
        ),
        // ---------- Tests ----------
        .testTarget(
            name: "MestroykaTests",
            dependencies: ["Mestroyka"],
        ),
        .testTarget(
            name: "MestroykaMLXTests",
            dependencies: ["MestroykaMLX"],
        ),
    ],
)
