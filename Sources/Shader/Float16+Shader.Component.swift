extension Float16: Shader.Component {
    @inlinable
    @inline(__always)
    public static var width: Int32 { 2 }

    @inlinable
    @inline(__always)
    public static func pair(_ words: Shader.Words, at offset: Int32) -> (x: Float16, y: Float16) {
        let word = words[offset]
        return (
            Float16(bitPattern: UInt16(truncatingIfNeeded: word)),
            Float16(bitPattern: UInt16(truncatingIfNeeded: word &>> 16))
        )
    }

    @inlinable
    @inline(__always)
    public static func put(_ x: Float16, _ y: Float16, to words: Shader.Words, at offset: Int32) {
        words[offset] = UInt32(x.bitPattern) | UInt32(y.bitPattern) &<< 16
    }

    @inlinable
    @inline(__always)
    public static func quad(_ words: Shader.Words, at offset: Int32) -> (x: Float16, y: Float16, z: Float16, w: Float16) {
        let wide = words[wide: offset]
        return (
            Float16(bitPattern: UInt16(truncatingIfNeeded: wide)),
            Float16(bitPattern: UInt16(truncatingIfNeeded: wide &>> 16)),
            Float16(bitPattern: UInt16(truncatingIfNeeded: wide &>> 32)),
            Float16(bitPattern: UInt16(truncatingIfNeeded: wide &>> 48))
        )
    }

    @inlinable
    @inline(__always)
    public static func put(_ x: Float16, _ y: Float16, _ z: Float16, _ w: Float16, to words: Shader.Words, at offset: Int32) {
        let low = UInt32(x.bitPattern) | UInt32(y.bitPattern) &<< 16
        let high = UInt32(z.bitPattern) | UInt32(w.bitPattern) &<< 16
        words[wide: offset] = UInt64(low) | UInt64(high) &<< 32
    }
}
