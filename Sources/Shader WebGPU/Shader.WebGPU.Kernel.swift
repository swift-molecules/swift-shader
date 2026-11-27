public import Shader

extension Shader.WebGPU {
    /// A kernel the page compiles from its WGSL, by the name its text gives its entry point.
    public struct Kernel: Sendable, Hashable {
        public let name: Swift.String
        /// The page's number for the kernel's pipeline.
        let handle: Int32
    }
}

extension Shader.WebGPU.Kernel {
    /// The kernel named so in its WGSL text, handed to the page to compile, which it does without the module
    /// waiting: a dispatch of it waits on the GPU's side until it is compiled.
    public init(name: Swift.String, text: Swift.String) {
        self.name = name
        #if os(WASI)
            var name = name
            var text = text
            handle = name.withUTF8 { named in
                text.withUTF8 { written in
                    unsafe shaderWebGPUKernel(named.baseAddress!, Int32(named.count), written.baseAddress!, Int32(written.count))
                }
            }
        #else
            handle = -1
        #endif
    }

    /// Runs the kernel at every place of a grid of `columns` by `rows`, after every dispatch before it, its
    /// buffers at the places of `heap`, in words, that `bases` gives by number, and its textures by number.
    public func dispatch(columns: Int, rows: Int, bases: [UInt32], textures: [Shader.WebGPU.Texture?] = []) {
        guard columns > 0, rows > 0 else { return }
        var all = [UInt32](repeating: 0, count: 32)
        for (number, base) in bases.prefix(32).enumerated() { all[number] = base }
        #if os(WASI)
            let handles = Shader.WebGPU.handles(textures)
            all.withUnsafeBufferPointer { words in
                handles.withUnsafeBufferPointer { handles in
                    unsafe shaderWebGPUDispatch(handle, Int32(clamping: columns), Int32(clamping: rows), words.baseAddress!, handles.baseAddress!)
                }
            }
        #endif
    }
}
