public import Shader

extension Shader {
    /// Kernels run on the browser's GPU through WebGPU, from WebAssembly: kernels written in WGSL by swift-shader-
    /// compiler, the one array of words, `heap`, their buffers lie in, and the dispatches that run them in order.
    ///
    /// The page holds the GPU: `Shader.WebGPU.script` is the JavaScript that gives the module its imports, from the
    /// module `shader_webgpu`, over a device and a canvas. Elsewhere than in WebAssembly nothing is sent.
    public enum WebGPU {}
}
