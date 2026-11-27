extension Shader {
    /// A texture of two dimensions, as vectors of red, green, blue and alpha: read at a place, sampled between
    /// places, or written at a place.
    @safe
    public struct Texture {
        #if SHADER
            @usableFromInline
            internal let number: Int32

            /// The texture bound at a number.
            @inlinable
            @inline(__always)
            public init(_ number: Int32) {
                self.number = number
            }
        #else
            @usableFromInline
            internal let pixels: Shader.Buffer<SIMD4<Float>>

            @usableFromInline
            internal let columns: Int32

            @usableFromInline
            internal let rows: Int32

            /// A texture of so many columns and rows over memory, a vector to a place, row by row.
            @inlinable
            public init(_ pixels: Shader.Buffer<SIMD4<Float>>, columns: Int32, rows: Int32) {
                self.pixels = pixels
                self.columns = columns
                self.rows = rows
            }
        #endif
    }
}

extension Shader.Texture {
    /// The vector at a place, which must lie in the texture.
    @inlinable
    @inline(__always)
    public func read(at place: Shader.Place) -> SIMD4<Float> {
        #if SHADER
            textureLoad(number, place.column, place.row)
            return SIMD4(texel(0), texel(1), texel(2), texel(3))
        #else
            return pixels[Int32(bitPattern: place.row) &* columns &+ Int32(bitPattern: place.column)]
        #endif
    }

    /// Puts a vector at a place, which must lie in the texture. A kernel writes a texture; a stage does not.
    @inlinable
    @inline(__always)
    public func write(_ vector: SIMD4<Float>, at place: Shader.Place) {
        #if SHADER
            textureStore(number, vector.x, vector.y, vector.z, vector.w, place.column, place.row)
        #else
            pixels[Int32(bitPattern: place.row) &* columns &+ Int32(bitPattern: place.column)] = vector
        #endif
    }

    /// The vector at a point between places, in the texture's own measure: the place in column `c` and row `r` has
    /// its middle at `(c + 0.5, r + 0.5)`. The four places around the point are weighed by how near each is, and a
    /// point beyond the edge reads the edge.
    @inlinable
    @inline(__always)
    public func sample(at point: SIMD2<Float>) -> SIMD4<Float> {
        #if SHADER
            textureSample(number, point.x, point.y)
            return SIMD4(texel(0), texel(1), texel(2), texel(3))
        #else
            let x = Swift.min(Swift.max(point.x - 0.5, 0), Float(columns - 1))
            let y = Swift.min(Swift.max(point.y - 0.5, 0), Float(rows - 1))
            let left = Int32(x.rounded(.down))
            let top = Int32(y.rounded(.down))
            let right = Swift.min(left + 1, columns - 1)
            let bottom = Swift.min(top + 1, rows - 1)
            let across = x - Float(left)
            let down = y - Float(top)
            let upper = pixels[top &* columns &+ left] * (1 - across) + pixels[top &* columns &+ right] * across
            let lower = pixels[bottom &* columns &+ left] * (1 - across) + pixels[bottom &* columns &+ right] * across
            return upper * (1 - down) + lower * down
        #endif
    }
}
