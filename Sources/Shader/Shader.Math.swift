public import Numeric

extension Shader {
    /// Functions of a `Float` that a GPU works its own way, so that their last bits differ from the CPU's: swift-numeric's,
    /// which a shader build makes the GPU's own.
    public enum Math {}
}

extension Shader.Math {
    @inlinable
    @inline(__always)
    public static func exp(_ x: Float) -> Float {
        Float.exp(x)
    }

    @inlinable
    @inline(__always)
    public static func sin(_ x: Float) -> Float {
        Float.sin(x)
    }

    @inlinable
    @inline(__always)
    public static func cos(_ x: Float) -> Float {
        Float.cos(x)
    }

    @inlinable
    @inline(__always)
    public static func atan2(_ y: Float, _ x: Float) -> Float {
        Float.atan2(y, x)
    }

    @inlinable
    @inline(__always)
    public static func pow(_ x: Float, _ y: Float) -> Float {
        Float.math.pow(x, y)
    }
}
