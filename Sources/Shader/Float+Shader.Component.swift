extension Float: Shader.Component {
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
    public static func write(_ x: Float, _ y: Float, _ z: Float, _ w: Float, to words: Shader.Words, at offset: Int32) {
        x.write(to: words, at: offset)
        y.write(to: words, at: offset &+ 4)
        z.write(to: words, at: offset &+ 8)
        w.write(to: words, at: offset &+ 12)
    }
}
