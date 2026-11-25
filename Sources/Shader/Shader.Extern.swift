#if SHADER
    extension Shader {
        @_extern(wasm, module: "shader", name: "load")
        @_extern(c, "shader_load")
        @usableFromInline
        internal static func load(_ buffer: Int32, _ offset: Int32) -> UInt32

        @_extern(wasm, module: "shader", name: "store")
        @_extern(c, "shader_store")
        @usableFromInline
        internal static func store(_ buffer: Int32, _ offset: Int32, _ word: UInt32)

        @_extern(wasm, module: "shader", name: "result")
        @_extern(c, "shader_result")
        @usableFromInline
        internal static func result(_ index: Int32, _ component: Float)

        /// Gives a vector from a function entry.
        @inlinable
        @inline(__always)
        public static func result(_ vector: SIMD4<Float>) {
            result(0, vector.x)
            result(1, vector.y)
            result(2, vector.z)
            result(3, vector.w)
        }
    }
#endif
