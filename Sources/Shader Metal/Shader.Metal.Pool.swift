#if canImport(Metal)
    public import Shader
    public import Metal
    public import Cardinal

    extension Shader.Metal {
        /// Buffers a renderer has finished with, kept for the next pass or frame that asks for one they fit, so a
        /// film draws its frames without making and clearing memory for every sheet. A buffer comes back only once
        /// the GPU has finished every command that used it. It keeps at most `bound` bytes, letting go of those given
        /// longest ago, and belongs to the one task that draws through it.
        public struct Pool {
            let bound: Int
            var buffers: [Int: [(buffer: any MTLBuffer, given: UInt64)]] = [:]
            var bytes = 0
            /// How many buffers were ever given.
            var given: UInt64 = 0

            public init(bound: Cardinal = 2_147_483_648) {
                self.bound = Int(bitPattern: bound)
            }
        }
    }

    extension Shader.Metal.Pool {
        /// The size a buffer of some bytes is made at: a power of two up to a mebibyte, and whole mebibytes above,
        /// so buffers of nearly one size are one size.
        public static func size(_ length: Cardinal) -> Cardinal {
            let length = Swift.max(Int(bitPattern: length), 256)
            guard length > 1 << 20 else { return Cardinal(UInt(1 << (Int.bitWidth - (length - 1).leadingZeroBitCount))) }
            return Cardinal(UInt((length + (1 << 20) - 1) & ~((1 << 20) - 1)))
        }

        /// The size among `sizes` a buffer of `size` is taken from: the smallest that holds it, and no more than
        /// twice its size, so that little of a buffer lies unused.
        public static func fitting(_ size: Cardinal, among sizes: some Swift.Sequence<Cardinal>) -> Cardinal? {
            var best: Cardinal?
            for other in sizes where other >= size && other <= size + size && other < best ?? .max { best = other }
            return best
        }

        /// A kept buffer that holds a size, if there is one, handed over to the one who takes it.
        public mutating func take(_ size: Cardinal) -> Sheet? {
            let asked = Int(bitPattern: size)
            guard let size = buffers[asked] == nil ? Self.fitting(size, among: buffers.keys.lazy.map { Cardinal(UInt($0)) }).map({ Int(bitPattern: $0) }) : asked,
                let held = buffers[size]?.popLast()
            else { return nil }
            if buffers[size]?.isEmpty == true { buffers[size] = nil }
            bytes -= size
            return Sheet(buffer: held.buffer)
        }

        /// Keeps a buffer the GPU has finished with.
        public mutating func give(_ sheet: consuming Sheet) {
            let buffer = sheet.buffer
            let length = buffer.length
            guard length <= bound else { return }
            given += 1
            buffers[length, default: []].append((buffer, given))
            bytes += length
            while bytes > bound, let oldest = buffers.min(by: { ($0.value.first?.given ?? .max) < ($1.value.first?.given ?? .max) })?.key {
                buffers[oldest]?.removeFirst()
                if buffers[oldest]?.isEmpty == true { buffers[oldest] = nil }
                bytes -= oldest
            }
        }
    }
#endif
