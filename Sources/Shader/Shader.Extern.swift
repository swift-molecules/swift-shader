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

    @_extern(wasm, module: "shader", name: "load_byte")
    @_extern(c, "shader_load_byte")
    @usableFromInline
    internal func loadByte(_ buffer: Int32, _ offset: Int32) -> UInt32

    @_extern(wasm, module: "shader", name: "store_byte")
    @_extern(c, "shader_store_byte")
    @usableFromInline
    internal func storeByte(_ buffer: Int32, _ offset: Int32, _ byte: UInt32)

    @_extern(wasm, module: "shader", name: "lane")
    @_extern(c, "shader_lane")
    @usableFromInline
    internal func lane() -> Int32

    @_extern(wasm, module: "shader", name: "lanes")
    @_extern(c, "shader_lanes")
    @usableFromInline
    internal func lanes() -> Int32

    @_extern(wasm, module: "shader", name: "barrier")
    @_extern(c, "shader_barrier")
    @usableFromInline
    internal func barrier()

    @_extern(wasm, module: "shader", name: "prefix")
    @_extern(c, "shader_prefix")
    @usableFromInline
    internal func prefix(_ number: Float) -> Float

    @_extern(wasm, module: "shader", name: "final")
    @_extern(c, "shader_final")
    @usableFromInline
    internal func final(_ number: Float) -> Float

    @_extern(wasm, module: "shader", name: "surface")
    @_extern(c, "shader_surface")
    @usableFromInline
    internal func surface(_ red: Float, _ green: Float, _ blue: Float, _ alpha: Float, _ column: UInt32, _ row: UInt32)






    @_extern(wasm, module: "shader", name: "load_wide")
    @_extern(c, "shader_load_wide")
    @usableFromInline
    internal func loadWide(_ buffer: Int32, _ offset: Int32) -> UInt64

    @_extern(wasm, module: "shader", name: "store_wide")
    @_extern(c, "shader_store_wide")
    @usableFromInline
    internal func storeWide(_ buffer: Int32, _ offset: Int32, _ words: UInt64)

    @_extern(wasm, module: "shader", name: "local")
    @_extern(c, "shader_local")
    @usableFromInline
    internal func local(_ number: Int32, _ count: Int32)

    @_extern(wasm, module: "shader", name: "local_load")
    @_extern(c, "shader_local_load")
    @usableFromInline
    internal func localLoad(_ number: Int32, _ index: Int32) -> UInt32

    @_extern(wasm, module: "shader", name: "local_store")
    @_extern(c, "shader_local_store")
    @usableFromInline
    internal func localStore(_ number: Int32, _ index: Int32, _ word: UInt32)

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
