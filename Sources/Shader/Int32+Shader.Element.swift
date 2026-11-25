extension Int32: Shader.Element, Shader.Component {
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

    @inlinable
    @inline(__always)
    public static func quad(_ words: Shader.Words, at offset: Int32) -> (x: Int32, y: Int32, z: Int32, w: Int32) {
        let low = words[wide: offset]
        let high = words[wide: offset &+ 8]
        return (Int32(truncatingIfNeeded: low), Int32(truncatingIfNeeded: low &>> 32), Int32(truncatingIfNeeded: high), Int32(truncatingIfNeeded: high &>> 32))
    }
}
