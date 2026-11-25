extension Shader {
    /// Code that runs at every place of a grid.
    public protocol Kernel {
        /// What happens at a place.
        func run(at place: Shader.Place)
    }
}

extension Shader.Kernel {
    /// Runs at every place of a grid, row by row, on the calling thread.
    @inlinable
    public func run(over grid: Shader.Grid) {
        var row: UInt32 = 0
        while row < grid.rows {
            var column: UInt32 = 0
            while column < grid.columns {
                run(at: Shader.Place(column: column, row: row))
                column += 1
            }
            row += 1
        }
    }
}
