#if SHADER
    // Free functions: a static one takes its type as a further argument.
    @_extern(wasm, module: "shader", name: "load")
    @_extern(c, "shader_load")
    @usableFromInline
    internal func load(_ buffer: Int32, _ offset: Int32) -> UInt32

    @_extern(wasm, module: "shader", name: "store")
    @_extern(c, "shader_store")
    @usableFromInline
    internal func store(_ buffer: Int32, _ offset: Int32, _ word: UInt32)

    @_extern(wasm, module: "shader", name: "result")
    @_extern(c, "shader_result")
    @usableFromInline
    internal func result(_ index: Int32, _ component: Float)

    extension Shader {
        /// Gives a vector from a function entry.
        @inlinable
        @inline(__always)
        public static func result(_ vector: SIMD4<Float>) {
            Shader::result(0, vector.x)
            Shader::result(1, vector.y)
            Shader::result(2, vector.z)
            Shader::result(3, vector.w)
        }
    }
#endif
