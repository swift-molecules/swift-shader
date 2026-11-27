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
    func shaderWebGPUDispatch(_ kernel: Int32, _ columns: Int32, _ rows: Int32, _ bases: UnsafePointer<UInt32>)

    @_extern(wasm, module: "shader_webgpu", name: "submit")
    @_extern(c)
    func shaderWebGPUSubmit()
#endif
