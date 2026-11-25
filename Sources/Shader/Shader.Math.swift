#if !SHADER
    public import Numeric
#endif

extension Shader {
    /// Functions of a `Float` that a GPU works its own way, so that their last bits differ from the CPU's.
    public enum Math {}
}

extension Shader.Math {
    @inlinable
    @inline(__always)
    public static func exp(_ x: Float) -> Float {
        #if SHADER
            mathExp(x)
        #else
            Float.exp(x)
        #endif
    }

    @inlinable
    @inline(__always)
    public static func sin(_ x: Float) -> Float {
        #if SHADER
            mathSin(x)
        #else
            Float.sin(x)
        #endif
    }

    @inlinable
    @inline(__always)
    public static func cos(_ x: Float) -> Float {
        #if SHADER
            mathCos(x)
        #else
            Float.cos(x)
        #endif
    }

    @inlinable
    @inline(__always)
    public static func atan2(_ y: Float, _ x: Float) -> Float {
        #if SHADER
            mathAtan2(y, x)
        #else
            Float.atan2(y, x)
        #endif
    }

    @inlinable
    @inline(__always)
    public static func pow(_ x: Float, _ y: Float) -> Float {
        #if SHADER
            mathPow(x, y)
        #else
            Float.math.pow(x, y)
        #endif
    }
}
