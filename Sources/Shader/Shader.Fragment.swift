extension Shader {
    /// Code that runs for every pixel a triangle covers, and gives the pixel's colour.
    public protocol Fragment {
        /// The stage over the memory it is handed.
        init(_ arguments: Shader.Arguments)

        /// The colour at a point of the target, which is a pixel's middle: `(column + 0.5, row + 0.5)`, rows counted
        /// from the top.
        func run(at point: SIMD2<Float>, _ handed: Shader.Handed) -> SIMD4<Float>
    }
}
