#if SHADER
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

    @_extern(wasm, module: "shader", name: "texture_load")
    @_extern(c, "shader_texture_load")
    @usableFromInline
    internal func textureLoad(_ texture: Int32, _ column: UInt32, _ row: UInt32)

    @_extern(wasm, module: "shader", name: "texture_sample")
    @_extern(c, "shader_texture_sample")
    @usableFromInline
    internal func textureSample(_ texture: Int32, _ x: Float, _ y: Float)

    @_extern(wasm, module: "shader", name: "texel")
    @_extern(c, "shader_texel")
    @usableFromInline
    internal func texel(_ component: Int32) -> Float

    @_extern(wasm, module: "shader", name: "texture_store")
    @_extern(c, "shader_texture_store")
    @usableFromInline
    internal func textureStore(_ texture: Int32, _ red: Float, _ green: Float, _ blue: Float, _ alpha: Float, _ column: UInt32, _ row: UInt32)

    @_extern(wasm, module: "shader", name: "position")
    @_extern(c, "shader_position")
    @usableFromInline
    internal func position(_ x: Float, _ y: Float, _ z: Float, _ w: Float)

    @_extern(wasm, module: "shader", name: "vary")
    @_extern(c, "shader_vary")
    @usableFromInline
    internal func vary(_ place: Int32, _ x: Float, _ y: Float, _ z: Float, _ w: Float)

    @_extern(wasm, module: "shader", name: "vary_flat")
    @_extern(c, "shader_vary_flat")
    @usableFromInline
    internal func varyFlat(_ place: Int32, _ x: UInt32, _ y: UInt32, _ z: UInt32, _ w: UInt32)

    @_extern(wasm, module: "shader", name: "varying")
    @_extern(c, "shader_varying")
    @usableFromInline
    internal func varying(_ place: Int32, _ component: Int32) -> Float

    @_extern(wasm, module: "shader", name: "varying_flat")
    @_extern(c, "shader_varying_flat")
    @usableFromInline
    internal func varyingFlat(_ place: Int32, _ component: Int32) -> UInt32
#endif
