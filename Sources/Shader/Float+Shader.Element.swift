extension Float: Shader.Element, Shader.Component {
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

    @inlinable
    @inline(__always)
    public static func quad(_ words: Shader.Words, at offset: Int32) -> (x: Float, y: Float, z: Float, w: Float) {
        let low = words[wide: offset]
        let high = words[wide: offset &+ 8]
        return (Float(bitPattern: UInt32(truncatingIfNeeded: low)), Float(bitPattern: UInt32(truncatingIfNeeded: low &>> 32)), Float(bitPattern: UInt32(truncatingIfNeeded: high)), Float(bitPattern: UInt32(truncatingIfNeeded: high &>> 32)))
    }
}
