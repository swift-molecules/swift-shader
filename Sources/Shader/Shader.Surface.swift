extension Shader {
    /// A texture a kernel writes, as vectors of red, green, blue and alpha.
    @safe
    public struct Surface {
        #if SHADER
            @inlinable
            @inline(__always)
            public init() {}
        #else
            @usableFromInline
            internal let pixels: Shader.Buffer<SIMD4<Float>>
            @usableFromInline
            internal let columns: Int32

            /// A surface of so many columns over memory, a vector to a place.
            @inlinable
            public init(_ pixels: Shader.Buffer<SIMD4<Float>>, columns: Int32) {
                self.pixels = pixels
                self.columns = columns
            }
        #endif
    }
}

extension Shader.Surface {
    /// Puts a vector at a place.
    @inlinable
    @inline(__always)
    public func write(_ vector: SIMD4<Float>, at place: Shader.Place) {
        #if SHADER
            surface(vector.x, vector.y, vector.z, vector.w, place.column, place.row)
        #else
            pixels[Int32(bitPattern: place.row) &* columns &+ Int32(bitPattern: place.column)] = vector
        #endif
    }
}
