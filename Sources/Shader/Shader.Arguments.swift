extension Shader {
    /// What a kernel is handed: the memory bound at each number.
    @safe
    public struct Arguments {
        #if SHADER
            @inlinable
            @inline(__always)
            public init() {}
        #else
            @usableFromInline
            internal let addresses: [UnsafeMutableRawPointer]

            @usableFromInline
            internal let textures: [Shader.Texture]

            /// The memory that begins at each address, and each texture, by its number.
            @unsafe
            @inlinable
            public init(_ addresses: [UnsafeMutableRawPointer], textures: [Shader.Texture] = []) {
                unsafe self.addresses = addresses
                self.textures = textures
            }
        #endif
    }
}

extension Shader.Arguments {
    /// The buffer bound at a number.
    @inlinable
    @inline(__always)
    public subscript<Element>(number: Int32) -> Shader.Buffer<Element> {
        #if SHADER
            Shader.Buffer(number)
        #else
            unsafe Shader.Buffer(addresses[Int(number)])
        #endif
    }
}

extension Shader.Arguments {
    /// The texture bound at a number. Textures are numbered apart from buffers.
    @inlinable
    @inline(__always)
    public func texture(_ number: Int32) -> Shader.Texture {
        #if SHADER
            Shader.Texture(number)
        #else
            textures[Int(number)]
        #endif
    }
}
