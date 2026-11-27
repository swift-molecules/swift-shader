import Shader
import Testing

enum `Shader Tests` {}

extension `Shader Tests` {
    struct Sum: Shader.Kernel {
        let from: Shader.Buffer<SIMD4<Float16>>
        let keys: Shader.Buffer<SIMD2<UInt64>>
        let to: Shader.Buffer<SIMD4<Float>>

        init(_ arguments: Shader.Arguments) {
            from = arguments[0]
            keys = arguments[1]
            to = arguments[2]
        }

        func run(at place: Shader.Place) {
            let index = Int32(place.row) * 3 + Int32(place.column)
            to[index] = SIMD4<Float>(from[index]) + SIMD4(repeating: Float(keys[0].y))
        }
    }

    @Suite
    struct Kernel {
        @Test
        func `A kernel visits every place, and buffers hold Metal's layout`() {
            var from = (0..<6).map { SIMD4<Float16>(Float16($0), 0.5, -1, 2) }
            var keys = [SIMD2<UInt64>(1, 10)]
            var to = [SIMD4<Float>](repeating: .zero, count: 6)
            from.withUnsafeMutableBytes { from in
                keys.withUnsafeMutableBytes { keys in
                    to.withUnsafeMutableBytes { to in
                        unsafe Sum(.init([from.baseAddress!, keys.baseAddress!, to.baseAddress!]))
                            .run(over: .init(columns: 3, rows: 2))
                    }
                }
            }
            #expect(to == (0..<6).map { SIMD4(Float($0) + 10, 10.5, 9, 12) })
        }
    }
}

extension `Shader Tests` {
    struct Blit: Shader.Vertex, Shader.Fragment {
        let sheet: Shader.Texture

        init(_ arguments: Shader.Arguments) {
            sheet = arguments.texture(0)
        }

        func run(vertex: UInt32, instance: UInt32) -> Shader.Corner {
            let x = Float((vertex << 1) & 2)
            let y = Float(vertex & 2)
            return .init(position: SIMD4(x * 2 - 1, 1 - y * 2, 0, 1), handed: .init(first: SIMD4(x, y, 0, 0), flat: SIMD4(instance, 0, 0, 0)))
        }

        func run(at point: SIMD2<Float>, _ handed: Shader.Handed) -> SIMD4<Float> {
            sheet.sample(at: point) * handed.first.x
        }
    }

    @Suite
    struct Texture {
        @Test
        func `A texture is read at a place, written at a place, and sampled between places with the edge beyond it`() {
            var pixels: [SIMD4<Float>] = [SIMD4(repeating: 0), SIMD4(repeating: 1), SIMD4(repeating: 2), SIMD4(repeating: 3)]
            pixels.withUnsafeMutableBytes { pixels in
                let texture = unsafe Shader.Texture(Shader.Buffer(pixels.baseAddress!), columns: 2, rows: 2)
                #expect(texture.read(at: .init(column: 1, row: 1)) == SIMD4(repeating: 3))
                #expect(texture.sample(at: SIMD2(1, 1)) == SIMD4(repeating: 1.5))
                #expect(texture.sample(at: SIMD2(0.5, 1.5)) == SIMD4(repeating: 2))
                #expect(texture.sample(at: SIMD2(-4, 9)) == SIMD4(repeating: 2))
                texture.write(SIMD4(repeating: 8), at: .init(column: 0, row: 0))
                #expect(texture.read(at: .init(column: 0, row: 0)) == SIMD4(repeating: 8))
                let blit = unsafe Blit(.init([], textures: [texture]))
                #expect(blit.run(vertex: 1, instance: 7).position == SIMD4(3, 1, 0, 1))
                #expect(blit.run(at: SIMD2(1.5, 1.5), .init(first: SIMD4(0.5, 0, 0, 0))) == SIMD4(repeating: 1.5))
            }
        }
    }
}
