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
}
