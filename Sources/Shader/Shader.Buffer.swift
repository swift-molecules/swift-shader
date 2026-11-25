extension Shader {
    /// Elements in memory a kernel reads and writes.
    @safe
    public struct Buffer<Element: Shader.Element> {
        @usableFromInline
        internal let words: Shader.Words

        #if SHADER
            /// The buffer bound at an index.
            @inlinable
            @inline(__always)
            public init(_ index: Int32) {
                words = Shader.Words(index: index)
            }
        #else
            /// The elements that begin at an address.
            @unsafe
            @inlinable
            public init(_ base: UnsafeMutableRawPointer) {
                unsafe words = Shader.Words(base: base)
            }
        #endif
    }
}

extension Shader.Buffer {
    /// The element at an index.
    @inlinable
    @inline(__always)
    public subscript(index: Int32) -> Element {
        get { Element(words, at: index &* Element.stride) }
        nonmutating set { newValue.write(to: words, at: index &* Element.stride) }
    }
}
