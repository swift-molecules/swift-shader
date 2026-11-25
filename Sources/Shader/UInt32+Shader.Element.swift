extension UInt32: Shader.Element, Shader.Component {
    @inlinable
    @inline(__always)
    public static var stride: Int32 { 4 }

    @inlinable
    @inline(__always)
    public init(_ words: Shader.Words, at offset: Int32) {
        self = words[offset]
    }

    @inlinable
    @inline(__always)
    public func write(to words: Shader.Words, at offset: Int32) {
        words[offset] = self
    }

    @inlinable
    @inline(__always)
    public static func quad(_ words: Shader.Words, at offset: Int32) -> (x: UInt32, y: UInt32, z: UInt32, w: UInt32) {
        let low = words[wide: offset]
        let high = words[wide: offset &+ 8]
        return (UInt32(truncatingIfNeeded: low), UInt32(truncatingIfNeeded: low &>> 32), UInt32(truncatingIfNeeded: high), UInt32(truncatingIfNeeded: high &>> 32))
    }
}
