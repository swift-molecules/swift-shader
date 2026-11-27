extension Shader {
    /// Code that runs for every corner of every triangle drawn, and says where the corner lies.
    public protocol Vertex {
        /// The stage over the memory it is handed.
        init(_ arguments: Shader.Arguments)

        /// The corner with a number, counted from 0, of the instance with a number.
        func run(vertex: UInt32, instance: UInt32) -> Shader.Corner
    }
}
