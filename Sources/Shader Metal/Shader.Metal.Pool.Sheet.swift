#if canImport(Metal)
    public import Shader
    public import Metal

    extension Shader.Metal.Pool {
        /// A buffer passing between the pool and the drawing that takes it: held by one of them at a time, taken
        /// out of the pool and given back to it, never both.
        public struct Sheet: ~Copyable {
            public let buffer: any MTLBuffer

            public init(buffer: any MTLBuffer) {
                self.buffer = buffer
            }
        }
    }
#endif
