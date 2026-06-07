// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Mestroyka",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "Mestroyka", targets: ["Mestroyka"]),
        .executable(name: "mestroyka", targets: ["MestroykaCLI"]),
    ],
    dependencies: [
        // On-device array / NN compute on Apple Silicon via Apple's MLX.
        // The LLM model + tokenizer layer is built on top of this core
        // (architecture code can be vendored from mlx-swift-examples' Libraries
        // or swift-transformers) as the agent loop lands.
        .package(url: "https://github.com/ml-explore/mlx-swift", .upToNextMinor(from: "0.31.3")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        // Agent / tool plumbing (MCP) is provided by the sibling packages and
        // wired in once the core loop lands:
        //   https://github.com/mihaelamj/SwiftMCPServer
        //   https://github.com/mihaelamj/SwiftMCPCore
    ],
    targets: [
        .target(
            name: "Mestroyka",
            dependencies: [
                .product(name: "MLX", package: "mlx-swift"),
                .product(name: "MLXNN", package: "mlx-swift"),
                .product(name: "MLXRandom", package: "mlx-swift"),
            ],
        ),
        .executableTarget(
            name: "MestroykaCLI",
            dependencies: [
                "Mestroyka",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
        ),
        .testTarget(
            name: "MestroykaTests",
            dependencies: ["Mestroyka"],
        ),
    ],
)
