public import Shader

extension Shader.WebGPU {
    /// A texture the page holds: a stage draws into it, and a stage or a kernel reads it at the number it is bound
    /// at.
    public struct Texture: Sendable, Hashable {
        public let columns: Int
        public let rows: Int
        public let format: Format

        /// The page's number for the texture.
        let handle: Int32
    }
}

extension Shader.WebGPU.Texture {
    /// What a texel holds.
    public enum Format: Int32, Sendable, Hashable, CaseIterable {
        /// Four half floats. A kernel can write such a texture.
        case rgba16float = 0
        /// One half float, read as red.
        case r16float = 1
        /// Four bytes, each a share of one.
        case rgba8unorm = 2
    }

    /// A texture of so many columns and rows, made by the page.
    public init(columns: Int, rows: Int, format: Format = .rgba16float) {
        self.columns = columns
        self.rows = rows
        self.format = format
        #if os(WASI)
            handle = shaderWebGPUTexture(Int32(clamping: columns), Int32(clamping: rows), format.rawValue)
        #else
            handle = -1
        #endif
    }

    /// Gives the texture's memory back, once every command sent before has run. It is not used after.
    public func release() {
        #if os(WASI)
            shaderWebGPURelease(handle)
        #endif
    }
}

extension Shader.WebGPU {
    /// The handles of textures by the number each is bound at, eight of them, -1 where none is.
    static func handles(_ textures: [Texture?]) -> [Int32] {
        var all = [Int32](repeating: -1, count: 8)
        for (number, texture) in textures.prefix(8).enumerated() { all[number] = texture?.handle ?? -1 }
        return all
    }
}
