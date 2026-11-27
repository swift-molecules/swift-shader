public import Shader

extension Shader.Metal.Timing {
    /// The kernels run under one name: how many times, and the GPU's seconds in all.
    public struct Entry: Sendable, Hashable {
        public var name: Swift.String
        public var count: Int
        public var seconds: Double

        public init(name: Swift.String, count: Int = 0, seconds: Double = 0) {
            self.name = name
            self.count = count
            self.seconds = seconds
        }
    }
}
