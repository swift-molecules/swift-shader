extension UInt64: Shader.Element, Shader.Component {
    @inlinable
    @inline(__always)
    public static var stride: Int32 { 8 }

    @inlinable
    @inline(__always)
    public init(_ words: Shader.Words, at offset: Int32) {
        self = UInt64(words[offset]) | UInt64(words[offset &+ 4]) &<< 32
    }

    @inlinable
    @inline(__always)
    public func write(to words: Shader.Words, at offset: Int32) {
        words[offset] = UInt32(truncatingIfNeeded: self)
        words[offset &+ 4] = UInt32(truncatingIfNeeded: self &>> 32)
    }
}
