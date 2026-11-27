extension Shader {
    /// An array a place of a grid keeps to itself and reads at places that vary, numbered so that a GPU keeps it apart
    /// from everything else the place holds: the number must be a constant, and each array of a kernel its own.
    public struct Local<let count: Int, Element: Shader.Word> {
        #if SHADER
            @usableFromInline
            internal let number: Int32
        #else
            @usableFromInline
            internal var words: InlineArray<count, UInt32>
        #endif

        /// The array numbered so, every element zero.
        @inlinable
        @inline(__always)
        public init(_ number: Int32) {
            #if SHADER
                self.number = number
                local(number, Int32(count))
            #else
                words = InlineArray(repeating: 0)
            #endif
        }
    }
}

extension Shader.Local {
    @inlinable
    @inline(__always)
    public subscript(index: Int32) -> Element {
        get {
            #if SHADER
                Element(word: localLoad(number, index))
            #else
                Element(word: words[Int(index)])
            #endif
        }
        set {
            #if SHADER
                localStore(number, index, newValue.word)
            #else
                words[Int(index)] = newValue.word
            #endif
        }
    }
}
