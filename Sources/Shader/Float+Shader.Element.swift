extension Float: Shader.Element {
    @inlinable
    @inline(__always)
    public static var stride: Int32 { 4 }

    @inlinable
    @inline(__always)
    public init(_ words: Shader.Words, at offset: Int32) {
        self = Float(bitPattern: words[offset])
    }

    @inlinable
    @inline(__always)
    public func write(to words: Shader.Words, at offset: Int32) {
        words[offset] = bitPattern
    }
}
