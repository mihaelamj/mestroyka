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
                .product(name: "MLXLLM", package: "mlx-swift-lm"),
                .product(name: "MLXLMCommon", package: "mlx-swift-lm"),
            ],
        ),
        // ---------- CLI ----------
        .executableTarget(
            name: "MestroykaCLI",
            dependencies: [
                "Mestroyka",
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
