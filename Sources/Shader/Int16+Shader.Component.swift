extension Int16: Shader.Component {
    @inlinable
    @inline(__always)
    public static var width: Int32 { 2 }

    @inlinable
    @inline(__always)
    public static func pair(_ words: Shader.Words, at offset: Int32) -> (x: Int16, y: Int16) {
        let word = words[offset]
        return (
            Int16(bitPattern: UInt16(truncatingIfNeeded: word)),
            Int16(bitPattern: UInt16(truncatingIfNeeded: word &>> 16))
        )
    }

    @inlinable
    @inline(__always)
    public static func put(_ x: Int16, _ y: Int16, to words: Shader.Words, at offset: Int32) {
        words[offset] = UInt32(UInt16(bitPattern: x)) | UInt32(UInt16(bitPattern: y)) &<< 16
    }
}
