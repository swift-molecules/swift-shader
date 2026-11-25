extension Int32: Shader.Component {
    @inlinable
    @inline(__always)
    public static var span: Int32 { 16 }

    @inlinable
    @inline(__always)
    public init(_ words: Shader.Words, at offset: Int32, component: Int32) {
        self.init(words, at: offset &+ 4 &* component)
    }

    @inlinable
    @inline(__always)
    public static func write(_ x: Int32, _ y: Int32, _ z: Int32, _ w: Int32, to words: Shader.Words, at offset: Int32) {
        x.write(to: words, at: offset)
        y.write(to: words, at: offset &+ 4)
        z.write(to: words, at: offset &+ 8)
        w.write(to: words, at: offset &+ 12)
    }
}
