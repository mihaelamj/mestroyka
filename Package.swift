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
        // On-device LLM inference on Apple Silicon via Apple's MLX.
        .package(url: "https://github.com/ml-explore/mlx-swift-examples.git", branch: "main"),
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
                .product(name: "MLXLLM", package: "mlx-swift-examples"),
                .product(name: "MLXLMCommon", package: "mlx-swift-examples"),
            ]
        ),
        .executableTarget(
            name: "MestroykaCLI",
            dependencies: [
                "Mestroyka",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "MestroykaTests",
            dependencies: ["Mestroyka"]
        ),
    ]
)
