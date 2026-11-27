extension Shader {
    /// A value of one word.
    public protocol Word {
        init(word: UInt32)
        var word: UInt32 { get }
    }
}

extension Float: Shader.Word {
    @inlinable
    @inline(__always)
    public init(word: UInt32) { self.init(bitPattern: word) }

    @inlinable
    @inline(__always)
    public var word: UInt32 { bitPattern }
}

extension Int32: Shader.Word {
    @inlinable
    @inline(__always)
    public init(word: UInt32) { self.init(bitPattern: word) }

    @inlinable
    @inline(__always)
    public var word: UInt32 { UInt32(bitPattern: self) }
}

extension UInt32: Shader.Word {
    @inlinable
    @inline(__always)
    public init(word: UInt32) { self = word }

    @inlinable
    @inline(__always)
    public var word: UInt32 { self }
}
