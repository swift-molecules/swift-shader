public import Shader

extension Shader.WebGPU {
    /// The one array of words every kernel's buffers lie in, as places handed out in turn: what a frame takes is
    /// given back all at once by `reset(to:)`, and what lies below a mark stays from frame to frame.
    public struct Heap: Sendable {
        /// The words the page holds.
        public private(set) var capacity: Int
        /// The first word not handed out.
        public private(set) var top: Int = 0

        /// A heap of so many words, held by the page.
        public init(words capacity: Int) {
            self.capacity = capacity
            #if os(WASI)
                shaderWebGPUReserve(Int32(clamping: capacity))
            #endif
        }
    }
}

extension Shader.WebGPU.Heap {
    /// The place of a buffer of so many words, each buffer beginning at a multiple of 64 words; nil where the
    /// heap is full.
    public mutating func take(_ words: Int) -> UInt32? {
        let start = (top + 63) & ~63
        guard start + words <= capacity else { return nil }
        top = start + words
        return UInt32(start)
    }

    /// A buffer holding a copy of some values, written by the page before the commands submitted next run.
    public mutating func take<Value>(_ values: [Value]) -> UInt32? {
        let words = (values.count * MemoryLayout<Value>.stride + 3) / 4
        guard let place = take(Swift.max(words, 1)) else { return nil }
        Self.write(values, at: place)
        return place
    }

    /// Writes values at a place, before the commands submitted next run.
    public static func write<Value>(_ values: [Value], at place: UInt32) {
        #if os(WASI)
            values.withUnsafeBytes { bytes in
                guard let base = bytes.baseAddress, unsafe !bytes.isEmpty else { return }
                unsafe shaderWebGPUWrite(Int32(bitPattern: place), base, Int32((bytes.count + 3) / 4))
            }
        #endif
    }

    /// Gives back every place handed out above a mark.
    public mutating func reset(to mark: Int = 0) {
        top = Swift.min(mark, top)
    }
}

extension Shader.WebGPU {
    /// Sends the dispatches made since the last send, and the writes before them, to the GPU.
    public static func submit() {
        #if os(WASI)
            shaderWebGPUSubmit()
        #endif
    }
}
