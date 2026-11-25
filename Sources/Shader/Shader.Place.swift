extension Shader {
    /// A place of a grid: its column and its row, counted from 0.
    public struct Place: Sendable, Hashable {
        public var column: UInt32
        public var row: UInt32

        @inlinable
        public init(column: UInt32, row: UInt32) {
            self.column = column
            self.row = row
        }
    }
}
