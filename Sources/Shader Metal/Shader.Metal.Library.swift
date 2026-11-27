#if canImport(Metal)
    public import Shader
    public import Metal
    public import Cardinal

    extension Shader.Metal {
        /// The machine's GPU, `lanes` queues on it, and kernels compiled from Metal text with Metal's normal maths:
        /// fused multiply-add and reordering allowed, infinities and NaN kept (`MTLMathMode.relaxed`).
        public struct Library: Sendable {
            public let device: any MTLDevice
            public let queues: [any MTLCommandQueue]
            public let kernels: [Swift.String: Shader.Metal.Kernel]

            /// The kernels named in `names` compiled from `source`, or nil where the machine has no GPU, the text
            /// does not compile, or a named kernel is missing.
            public init?(source: Swift.String, names: [Swift.String], lanes: Cardinal = 8) {
                guard let device = MTLCreateSystemDefaultDevice() else { return nil }
                let queues = (0..<Swift.max(Int(bitPattern: lanes), 1)).compactMap { _ in device.makeCommandQueue() }
                guard !queues.isEmpty else { return nil }
                let options = MTLCompileOptions()
                options.mathMode = .relaxed
                let library: any MTLLibrary
                // swift-linter:disable:next do throws for typed catch
                // REASON: MTLDevice.makeLibrary(source:options:) throws untyped; a compile failure leaves no library.
                do {
                    library = try device.makeLibrary(source: source, options: options)
                } catch {
                    return nil
                }
                var kernels: [Swift.String: Shader.Metal.Kernel] = [:]
                for name in names {
                    guard let function = library.makeFunction(name: name) else { return nil }
                    // swift-linter:disable:next do throws for typed catch
                    // REASON: MTLDevice.makeComputePipelineState(function:) throws untyped; a failure leaves no library.
                    do {
                        kernels[name] = Shader.Metal.Kernel(name: name, pipeline: try device.makeComputePipelineState(function: function))
                    } catch {
                        return nil
                    }
                }
                self.device = device
                self.queues = queues
                self.kernels = kernels
            }
        }
    }
#endif
