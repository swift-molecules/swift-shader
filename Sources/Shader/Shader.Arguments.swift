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

            /// The memory that begins at each address, by its number.
            @unsafe
            @inlinable
            public init(_ addresses: [UnsafeMutableRawPointer]) {
                unsafe self.addresses = addresses
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
