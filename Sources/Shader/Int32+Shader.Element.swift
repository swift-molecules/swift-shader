extension Int32: Shader.Element {
    @inlinable
    @inline(__always)
    public static var stride: Int32 { 4 }

    @inlinable
    @inline(__always)
    public init(_ words: Shader.Words, at offset: Int32) {
        self = Int32(bitPattern: words[offset])
    }

    @inlinable
    @inline(__always)
    public func write(to words: Shader.Words, at offset: Int32) {
        words[offset] = UInt32(bitPattern: self)
    }
}
