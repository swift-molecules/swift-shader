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
