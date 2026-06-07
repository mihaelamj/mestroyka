import MLX

public extension MLXOracle {
    /// Forces subsequent MLX work onto the CPU.
    ///
    /// Use when the Metal GPU library is unavailable (for example a plain
    /// `swift run` build that did not produce `mlx.metallib`). CPU inference is
    /// slower but lets the agent run anywhere Apple silicon does.
    static func useCPUDevice() {
        Device.setDefault(device: Device(.cpu))
    }
}
