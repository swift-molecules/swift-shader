public import Shader

extension Shader.WebGPU {
    /// A vertex and a fragment stage the page compiles from their WGSL into one pipeline that draws triangles into a
    /// target of one format with one blend.
    public struct Stage: Sendable, Hashable {
        public let name: Swift.String

        /// The page's number for the pipeline.
        let handle: Int32
    }
}

extension Shader.WebGPU.Stage {
    /// The stages named so in their WGSL texts, handed to the page to compile, which it does without the module
    /// waiting: a draw waits on the GPU's side until they are compiled. `format` is the target's, or nil for the
    /// page's canvas.
    public init(
        vertex: Swift.String,
        text vertexText: Swift.String,
        fragment: Swift.String,
        text fragmentText: Swift.String,
        format: Shader.WebGPU.Texture.Format?,
        blend: Shader.WebGPU.Blend = .replace
    ) {
        name = fragment
        #if os(WASI)
            let state: [Int32] = [
                format?.rawValue ?? -1,
                blend.color.operation.rawValue, blend.color.source.rawValue, blend.color.target.rawValue,
                blend.alpha.operation.rawValue, blend.alpha.source.rawValue, blend.alpha.target.rawValue,
            ]
            let texts = [vertex, vertexText, fragment, fragmentText].map { Swift.Array($0.utf8) }
            let all = Swift.Array(texts.joined())
            let counts = texts.map { Int32($0.count) }
            handle = all.withUnsafeBufferPointer { all in
                counts.withUnsafeBufferPointer { counts in
                    state.withUnsafeBufferPointer { state in
                        unsafe shaderWebGPUStage(all.baseAddress!, counts.baseAddress!, state.baseAddress!)
                    }
                }
            }
        #else
            handle = -1
        #endif
    }

    /// Draws so many corners, three to a triangle, so many times over, in the pass that is open, after everything
    /// sent before: its buffers at the places of `heap`, in words, that `bases` gives by number, and its textures
    /// by number. `within` is the part of the target it may change, as left, top, width and height in pixels, or
    /// nil for all of it.
    public func draw(
        vertices: Int,
        instances: Int = 1,
        bases: [UInt32],
        textures: [Shader.WebGPU.Texture?] = [],
        within: SIMD4<Int32>? = nil
    ) {
        guard vertices > 0, instances > 0 else { return }
        var all = [UInt32](repeating: 0, count: 32)
        for (number, base) in bases.prefix(32).enumerated() { all[number] = base }
        #if os(WASI)
            let handles = Shader.WebGPU.handles(textures)
            let area = within ?? SIMD4(-1, -1, -1, -1)
            let counts: [Int32] = [Int32(clamping: vertices), Int32(clamping: instances), area.x, area.y, area.z, area.w]
            all.withUnsafeBufferPointer { words in
                handles.withUnsafeBufferPointer { handles in
                    counts.withUnsafeBufferPointer { counts in
                        unsafe shaderWebGPUDraw(handle, counts.baseAddress!, words.baseAddress!, handles.baseAddress!)
                    }
                }
            }
        #endif
    }
}
