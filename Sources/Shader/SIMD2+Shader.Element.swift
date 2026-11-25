extension SIMD2: Shader.Element where Scalar == UInt64 {
    @inlinable
    @inline(__always)
    public static var stride: Int32 { 16 }

    @inlinable
    @inline(__always)
    public init(_ words: Shader.Words, at offset: Int32) {
        self.init(Self.number(words, at: offset), Self.number(words, at: offset &+ 8))
    }

    @inlinable
    @inline(__always)
    public func write(to words: Shader.Words, at offset: Int32) {
        Self.write(x, to: words, at: offset)
        Self.write(y, to: words, at: offset &+ 8)
    }

    @inlinable
    @inline(__always)
    internal static func number(_ words: Shader.Words, at offset: Int32) -> UInt64 {
        UInt64(words[offset]) | UInt64(words[offset &+ 4]) &<< 32
    }

    @inlinable
    @inline(__always)
    internal static func write(_ number: UInt64, to words: Shader.Words, at offset: Int32) {
        words[offset] = UInt32(truncatingIfNeeded: number)
        words[offset &+ 4] = UInt32(truncatingIfNeeded: number &>> 32)
    }
}
