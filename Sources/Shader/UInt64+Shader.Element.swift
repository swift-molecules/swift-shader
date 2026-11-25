extension UInt64: Shader.Element, Shader.Component {
    @inlinable
    @inline(__always)
    public static var stride: Int32 { 8 }

    @inlinable
    @inline(__always)
    public init(_ words: Shader.Words, at offset: Int32) {
        self = words[wide: offset]
    }

    @inlinable
    @inline(__always)
    public func write(to words: Shader.Words, at offset: Int32) {
        words[wide: offset] = self
    }
}
