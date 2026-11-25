extension UInt8: Shader.Element {
    @inlinable
    @inline(__always)
    public static var stride: Int32 { 1 }

    @inlinable
    @inline(__always)
    public init(_ words: Shader.Words, at offset: Int32) {
        self = words[byte: offset]
    }

    @inlinable
    @inline(__always)
    public func write(to words: Shader.Words, at offset: Int32) {
        words[byte: offset] = self
    }
}
