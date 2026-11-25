extension Shader {
    /// A grid of places: how many columns and rows it has.
    public struct Grid: Sendable, Hashable {
        public var columns: UInt32
        public var rows: UInt32

        @inlinable
        public init(columns: UInt32, rows: UInt32) {
            self.columns = columns
            self.rows = rows
        }
    }
}
