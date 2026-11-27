extension Shader {
    /// What a vertex stage hands the fragment stage beside the position: two vectors that vary over the triangle
    /// between its corners, and one of whole numbers that is the same all over it, taken from the triangle's first
    /// corner.
    public struct Handed: Sendable, Hashable {
        public var first: SIMD4<Float>
        public var second: SIMD4<Float>
        public var flat: SIMD4<UInt32>

        @inlinable
        @inline(__always)
        public init(first: SIMD4<Float> = .zero, second: SIMD4<Float> = .zero, flat: SIMD4<UInt32> = .zero) {
            self.first = first
            self.second = second
            self.flat = flat
        }
    }
}

#if SHADER
    extension Shader.Handed {
        /// What the vertex stage handed this fragment.
        @inlinable
        @inline(__always)
        public static var taken: Self {
            Self(
                first: SIMD4(varying(0, 0), varying(0, 1), varying(0, 2), varying(0, 3)),
                second: SIMD4(varying(1, 0), varying(1, 1), varying(1, 2), varying(1, 3)),
                flat: SIMD4(varyingFlat(2, 0), varyingFlat(2, 1), varyingFlat(2, 2), varyingFlat(2, 3))
            )
        }
    }
#endif
