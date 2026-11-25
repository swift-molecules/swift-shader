extension Shader {
    /// Places that run side by side in one row of a grid, each in a lane of its own. On the CPU there is one lane.
    public enum Lane {}
}

extension Shader.Lane {
    /// Which lane this is, counted from 0.
    @inlinable
    @inline(__always)
    public static var index: Int32 {
        #if SHADER
            lane()
        #else
            0
        #endif
    }

    /// How many lanes run side by side.
    @inlinable
    @inline(__always)
    public static var count: Int32 {
        #if SHADER
            lanes()
        #else
            1
        #endif
    }

    /// Waits until every lane has come here and what they wrote can be read.
    @inlinable
    @inline(__always)
    public static func wait() {
        #if SHADER
            barrier()
        #endif
    }

    /// The sum of a number over the lanes up to and with this one.
    @inlinable
    @inline(__always)
    public static func sum(_ number: Float) -> Float {
        #if SHADER
            prefix(number)
        #else
            number
        #endif
    }

    /// The number the last lane holds.
    @inlinable
    @inline(__always)
    public static func last(_ number: Float) -> Float {
        #if SHADER
            final(number)
        #else
            number
        #endif
    }
}
