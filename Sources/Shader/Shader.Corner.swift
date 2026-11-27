extension Shader {
    /// What a vertex stage gives for a corner of a triangle: where it lies, in clip space, and what it hands on.
    ///
    /// Clip space is the GPU's: after division by `w`, `x` runs from -1 at the target's left edge to 1 at its right,
    /// and `y` from -1 at its bottom edge to 1 at its top.
    public struct Corner: Sendable, Hashable {
        public var position: SIMD4<Float>
        public var handed: Shader.Handed

        @inlinable
        @inline(__always)
        public init(position: SIMD4<Float>, handed: Shader.Handed = .init()) {
            self.position = position
            self.handed = handed
        }
    }
}

#if SHADER
    extension Shader {
        /// Gives a corner from a vertex entry.
        @inlinable
        @inline(__always)
        public static func give(_ corner: Shader.Corner) {
            position(corner.position.x, corner.position.y, corner.position.z, corner.position.w)
            vary(0, corner.handed.first.x, corner.handed.first.y, corner.handed.first.z, corner.handed.first.w)
            vary(1, corner.handed.second.x, corner.handed.second.y, corner.handed.second.z, corner.handed.second.w)
            varyFlat(2, corner.handed.flat.x, corner.handed.flat.y, corner.handed.flat.z, corner.handed.flat.w)
        }
    }
#endif
