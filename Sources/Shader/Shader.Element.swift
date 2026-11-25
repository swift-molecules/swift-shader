extension Shader {
    /// A value a buffer holds.
    public protocol Element {
        /// How many bytes apart elements lie: a multiple of 4.
        static var stride: Int32 { get }

        /// The value at a byte offset.
        init(_ words: Shader.Words, at offset: Int32)

        /// Puts the value at a byte offset.
        func write(to words: Shader.Words, at offset: Int32)
    }
}
