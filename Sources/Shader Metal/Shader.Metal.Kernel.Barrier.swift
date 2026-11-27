#if canImport(Metal)
    public import Shader

    extension Shader.Metal.Kernel {
        /// Whether a dispatch is followed by a memory barrier over buffers and textures.
        public enum Barrier: Sendable, Hashable {
            case none
            case after
        }
    }
#endif
