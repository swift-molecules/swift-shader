#if canImport(Metal)
    public import Shader
    public import Metal

    extension Shader.Metal {
        /// A call to the GPU that failed, and why.
        public struct Failure: Swift.Error, Sendable, Hashable {
            public let call: Swift.String
            public let reason: Swift.String?

            public init(_ call: Swift.String, reason: Swift.String? = nil) {
                self.call = call
                self.reason = reason
            }
        }
    }

    extension Shader.Metal.Failure {
        /// Why commands the GPU has finished did not complete, or nil if they did.
        public init?(_ commands: any MTLCommandBuffer) {
            guard commands.status != .completed else { return nil }
            guard let error = commands.error else {
                self.init("commit()", reason: "status \(commands.status.rawValue)")
                return
            }
            self.init("commit()", reason: "\(error)")
        }
    }
#endif
