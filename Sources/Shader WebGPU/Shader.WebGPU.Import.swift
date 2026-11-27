#if os(WASI)
    // The functions the page gives the module: see `Shader.WebGPU.script`.
    @_extern(wasm, module: "shader_webgpu", name: "kernel")
    @_extern(c)
    func shaderWebGPUKernel(_ name: UnsafePointer<UInt8>, _ nameCount: Int32, _ text: UnsafePointer<UInt8>, _ textCount: Int32) -> Int32

    @_extern(wasm, module: "shader_webgpu", name: "reserve")
    @_extern(c)
    func shaderWebGPUReserve(_ words: Int32)

    @_extern(wasm, module: "shader_webgpu", name: "write")
    @_extern(c)
    func shaderWebGPUWrite(_ place: Int32, _ words: UnsafeRawPointer, _ count: Int32)

    @_extern(wasm, module: "shader_webgpu", name: "dispatch")
    @_extern(c)
    func shaderWebGPUDispatch(_ kernel: Int32, _ columns: Int32, _ rows: Int32, _ bases: UnsafePointer<UInt32>, _ textures: UnsafePointer<Int32>)

    @_extern(wasm, module: "shader_webgpu", name: "submit")
    @_extern(c)
    func shaderWebGPUSubmit()

    @_extern(wasm, module: "shader_webgpu", name: "show")
    @_extern(c)
    func shaderWebGPUShow(_ place: Int32, _ columns: Int32, _ rows: Int32)

    @_extern(wasm, module: "shader_webgpu", name: "read")
    @_extern(c)
    func shaderWebGPURead(_ place: Int32, _ count: Int32, _ into: UnsafeMutableRawPointer, _ token: Int32)

    @_extern(wasm, module: "shader_webgpu", name: "texture")
    @_extern(c)
    func shaderWebGPUTexture(_ columns: Int32, _ rows: Int32, _ format: Int32) -> Int32

    @_extern(wasm, module: "shader_webgpu", name: "release")
    @_extern(c)
    func shaderWebGPURelease(_ texture: Int32)

    @_extern(wasm, module: "shader_webgpu", name: "stage")
    @_extern(c)
    func shaderWebGPUStage(_ texts: UnsafePointer<UInt8>, _ counts: UnsafePointer<Int32>, _ state: UnsafePointer<Int32>) -> Int32

    @_extern(wasm, module: "shader_webgpu", name: "begin")
    @_extern(c)
    func shaderWebGPUBegin(_ target: Int32, _ clears: Int32, _ red: Float, _ green: Float, _ blue: Float, _ alpha: Float)

    @_extern(wasm, module: "shader_webgpu", name: "draw")
    @_extern(c)
    func shaderWebGPUDraw(_ stage: Int32, _ counts: UnsafePointer<Int32>, _ bases: UnsafePointer<UInt32>, _ textures: UnsafePointer<Int32>)

    @_extern(wasm, module: "shader_webgpu", name: "end")
    @_extern(c)
    func shaderWebGPUEnd()
#endif
