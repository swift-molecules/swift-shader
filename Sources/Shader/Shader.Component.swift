extension Shader {
    /// A number a buffer holds vectors of.
    public protocol Component {
        /// How many bytes a component takes.
        static var width: Int32 { get }

        /// Two components at a byte offset that is a multiple of 4.
        static func pair(_ words: Shader.Words, at offset: Int32) -> (x: Self, y: Self)

        /// Puts two components at a byte offset that is a multiple of 4.
        static func put(_ x: Self, _ y: Self, to words: Shader.Words, at offset: Int32)

        /// Four components at a byte offset that is a multiple of 8.
        static func quad(_ words: Shader.Words, at offset: Int32) -> (x: Self, y: Self, z: Self, w: Self)

        /// Puts four components at a byte offset that is a multiple of 8.
        static func put(_ x: Self, _ y: Self, _ z: Self, _ w: Self, to words: Shader.Words, at offset: Int32)
    }
}

extension Shader.Component where Self: Shader.Element {
    @inlinable
    @inline(__always)
    public static var width: Int32 { stride }

    @inlinable
    @inline(__always)
    public static func pair(_ words: Shader.Words, at offset: Int32) -> (x: Self, y: Self) {
        (Self(words, at: offset), Self(words, at: offset &+ stride))
    }

    @inlinable
    @inline(__always)
    public static func put(_ x: Self, _ y: Self, to words: Shader.Words, at offset: Int32) {
        x.write(to: words, at: offset)
        y.write(to: words, at: offset &+ stride)
    }
}

extension Shader.Component {
    @inlinable
    @inline(__always)
    public static func quad(_ words: Shader.Words, at offset: Int32) -> (x: Self, y: Self, z: Self, w: Self) {
        let low = pair(words, at: offset)
        let high = pair(words, at: offset &+ 2 &* width)
        return (low.x, low.y, high.x, high.y)
    }

    @inlinable
    @inline(__always)
    public static func put(_ x: Self, _ y: Self, _ z: Self, _ w: Self, to words: Shader.Words, at offset: Int32) {
        put(x, y, to: words, at: offset)
        put(z, w, to: words, at: offset &+ 2 &* width)
    }
}

extension SIMD2: Shader.Element where Scalar: Shader.Component {
    @inlinable
    @inline(__always)
    public static var stride: Int32 { 2 &* Scalar.width }

    @inlinable
    @inline(__always)
    public init(_ words: Shader.Words, at offset: Int32) {
        let pair = Scalar.pair(words, at: offset)
        self.init(pair.x, pair.y)
    }

    @inlinable
    @inline(__always)
    public func write(to words: Shader.Words, at offset: Int32) {
        Scalar.put(x, y, to: words, at: offset)
    }
}

extension SIMD4: Shader.Element where Scalar: Shader.Component {
    @inlinable
    @inline(__always)
    public static var stride: Int32 { 4 &* Scalar.width }

    @inlinable
    @inline(__always)
    public init(_ words: Shader.Words, at offset: Int32) {
        let quad = Scalar.quad(words, at: offset)
        self.init(quad.x, quad.y, quad.z, quad.w)
    }

    @inlinable
    @inline(__always)
    public func write(to words: Shader.Words, at offset: Int32) {
        Scalar.put(x, y, z, w, to: words, at: offset)
    }
}
