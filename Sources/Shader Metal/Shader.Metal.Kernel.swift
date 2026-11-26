#if canImport(Metal)
    public import Shader
    public import Metal

    extension Shader.Metal {
        /// One compiled kernel, by the name its text gives it.
        public struct Kernel: Sendable {
            public let name: Swift.String
            public let pipeline: any MTLComputePipelineState

            public init(name: Swift.String, pipeline: any MTLComputePipelineState) {
                self.name = name
                self.pipeline = pipeline
            }
        }
    }

    extension Shader.Metal.Kernel {
        /// Encodes the kernel over a grid of `width` by `height` on an encoder, named for the kernel, followed by a
        /// barrier where `barrier` says so; nothing for an empty grid. Without a `group` a row of threads is 256
        /// wide and a grid of rows is drawn in squares of 16.
        public func dispatch(
            on encoder: any MTLComputeCommandEncoder,
            barrier: Bool,
            width: Int,
            height: Int,
            group: (width: Int, height: Int)? = nil,
            _ bind: (any MTLComputeCommandEncoder) -> Void
        ) {
            guard width > 0, height > 0 else { return }
            encoder.label = name
            encoder.setComputePipelineState(pipeline)
            bind(encoder)
            let wide = group?.width ?? (height == 1 ? Swift.min(pipeline.maxTotalThreadsPerThreadgroup, 256) : 16)
            let tall = group?.height ?? (height == 1 ? 1 : Swift.max(1, Swift.min(16, pipeline.maxTotalThreadsPerThreadgroup / 16)))
            encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: MTLSize(width: wide, height: tall, depth: 1))
            if barrier { encoder.memoryBarrier(scope: [.buffers, .textures]) }
        }
    }
#endif
