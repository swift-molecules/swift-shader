extension Shader {
    /// A number a buffer holds vectors of four of.
    public protocol Component {
        /// How many bytes apart vectors lie.
        static var span: Int32 { get }

        /// A component of the vector at a byte offset.
        init(_ words: Shader.Words, at offset: Int32, component: Int32)

        /// Puts a vector's four components at a byte offset.
        static func write(_ x: Self, _ y: Self, _ z: Self, _ w: Self, to words: Shader.Words, at offset: Int32)
    }
}

extension SIMD4: Shader.Element where Scalar: Shader.Component {
    @inlinable
    @inline(__always)
    public static var stride: Int32 { Scalar.span }

    @inlinable
    @inline(__always)
    public init(_ words: Shader.Words, at offset: Int32) {
        self.init(
            Scalar(words, at: offset, component: 0),
            Scalar(words, at: offset, component: 1),
            Scalar(words, at: offset, component: 2),
            Scalar(words, at: offset, component: 3)
        )
    }

    @inlinable
    @inline(__always)
    public func write(to words: Shader.Words, at offset: Int32) {
        Scalar.write(x, y, z, w, to: words, at: offset)
    }
}
