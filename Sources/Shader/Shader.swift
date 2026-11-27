/// Code that runs at every place of a grid, on the CPU or a GPU.
public enum Shader {}

#if SHADER
    extension Shader {
        /// Gives a vector from a function entry.
        @inlinable
        @inline(__always)
        public static func result(_ vector: SIMD4<Float>) {
            Shader::result(0, vector.x)
            Shader::result(1, vector.y)
            Shader::result(2, vector.z)
            Shader::result(3, vector.w)
        }
    }
#endif
