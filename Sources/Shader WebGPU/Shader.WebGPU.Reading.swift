public import Shader

extension Shader.WebGPU {
    /// Reads words of the heap once the GPU has run every command sent before, without waiting for it: a page
    /// cannot wait for the GPU within a turn, so `landed` is called on a later turn, with the words, or with nil
    /// where they could not be read. Elsewhere than in WebAssembly it is called at once with nil.
    public static func read(at place: UInt32, words count: Int, _ landed: @escaping @Sendable ([UInt32]?) -> Void) {
        #if os(WASI)
            let words = UnsafeMutablePointer<UInt32>.allocate(capacity: Swift.max(count, 1))
            let token = unsafe Reading.waiting.add(Reading(address: UInt(bitPattern: words), count: count, landed: landed))
            unsafe shaderWebGPURead(Int32(bitPattern: place), Int32(clamping: count), UnsafeMutableRawPointer(words), token)
        #else
            landed(nil)
        #endif
    }
}

extension Shader.WebGPU {
    /// A read of the heap the page has not answered yet: the address of the words the page writes, and who is told.
    struct Reading {
        let address: UInt
        let count: Int
        let landed: @Sendable ([UInt32]?) -> Void
    }
}

extension Shader.WebGPU.Reading {
    /// The reads not yet answered, by the number the page answers each with.
    struct Waiting {
        var next: Int32 = 0
        var all: [Int32: Shader.WebGPU.Reading] = [:]

        mutating func add(_ reading: Shader.WebGPU.Reading) -> Int32 {
            next &+= 1
            all[next] = reading
            return next
        }
    }

    /// A module in a page runs on one thread, and only the page's answers take a reading out.
    nonisolated(unsafe) static var waiting = Waiting()
}

#if os(WASI)
    /// The page's answer to a read: its words are in place, or, `succeeded` zero, they could not be read.
    @_expose(wasm, "shader_webgpu_landed")
    @_cdecl("shader_webgpu_landed")
    public func shaderWebGPULanded(_ token: Int32, _ succeeded: Int32) {
        guard let reading = unsafe Shader.WebGPU.Reading.waiting.all.removeValue(forKey: token),
            let words = unsafe UnsafeMutablePointer<UInt32>(bitPattern: reading.address)
        else { return }
        let read = succeeded != 0 ? unsafe Array(UnsafeBufferPointer(start: words, count: reading.count)) : nil
        unsafe words.deallocate()
        reading.landed(read)
    }
#endif
