extension Float16: Shader.Component {
    @inlinable
    @inline(__always)
    public static var span: Int32 { 8 }

    @inlinable
    @inline(__always)
    public init(_ words: Shader.Words, at offset: Int32, component: Int32) {
        let word = words[offset &+ 4 &* (component &>> 1)]
        self.init(bitPattern: UInt16(truncatingIfNeeded: word &>> (16 &* UInt32(bitPattern: component & 1))))
    }

    @inlinable
    @inline(__always)
    public static func write(_ x: Float16, _ y: Float16, _ z: Float16, _ w: Float16, to words: Shader.Words, at offset: Int32) {
        words[offset] = pair(x, y)
        words[offset &+ 4] = pair(z, w)
    }

    @inlinable
    @inline(__always)
    internal static func pair(_ low: Float16, _ high: Float16) -> UInt32 {
        UInt32(low.bitPattern) | UInt32(high.bitPattern) &<< 16
    }
}
