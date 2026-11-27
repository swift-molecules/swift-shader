public import Shader
public import Cardinal

extension Shader.Metal.Timing {
    /// The kernels run under one name: how many times, and the GPU's seconds in all.
    public struct Entry: Sendable, Hashable {
        public var name: Swift.String
        public var count: Int
        public var seconds: Double

        public init(name: Swift.String, count: Cardinal = 0, seconds: Double = 0) {
            self.name = name
            self.count = Int(bitPattern: count)
            self.seconds = seconds
        }
    }
}
