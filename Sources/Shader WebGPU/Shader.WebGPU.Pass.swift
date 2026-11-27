public import Shader

extension Shader.WebGPU {
    /// A run of draws into one target, sent in order with the dispatches around it.
    public enum Pass {}
}

extension Shader.WebGPU.Pass {
    /// Opens a pass into a texture, or into the page's canvas for the frame the page is in where `target` is nil.
    /// The target first becomes `clear` all over, or keeps what it holds where `clear` is nil.
    public static func begin(_ target: Shader.WebGPU.Texture?, clear: SIMD4<Float>? = nil) {
        #if os(WASI)
            let color = clear ?? .zero
            shaderWebGPUBegin(target?.handle ?? -1, clear == nil ? 0 : 1, color.x, color.y, color.z, color.w)
        #endif
    }

    /// Closes the pass that is open.
    public static func end() {
        #if os(WASI)
            shaderWebGPUEnd()
        #endif
    }
}
