extension Shader {
    /// A buffer's memory as words of 32 bits, read and written at byte offsets that are multiples of 4.
    @safe
    public struct Words {
        #if SHADER
            @usableFromInline
            internal let index: Int32

            @inlinable
            @inline(__always)
            internal init(index: Int32) {
                self.index = index
            }
        #else
            @usableFromInline
            internal let base: UnsafeMutableRawPointer

            @unsafe
            @inlinable
            internal init(base: UnsafeMutableRawPointer) {
                unsafe self.base = unsafe base
            }
        #endif
    }
}

extension Shader.Words {
    /// The word at a byte offset.
    @inlinable
    @inline(__always)
    public subscript(offset: Int32) -> UInt32 {
        get {
            #if SHADER
                load(index, offset)
            #else
                UInt32(littleEndian: unsafe base.loadUnaligned(fromByteOffset: Int(offset), as: UInt32.self))
            #endif
        }
        nonmutating set {
            #if SHADER
                store(index, offset, newValue)
            #else
                unsafe base.storeBytes(of: newValue.littleEndian, toByteOffset: Int(offset), as: UInt32.self)
            #endif
        }
    }
}

extension Shader.Words {
    /// The byte at an offset.
    @inlinable
    @inline(__always)
    public subscript(byte offset: Int32) -> UInt8 {
        get {
            #if SHADER
                UInt8(truncatingIfNeeded: loadByte(index, offset))
            #else
                unsafe base.load(fromByteOffset: Int(offset), as: UInt8.self)
            #endif
        }
        nonmutating set {
            #if SHADER
                storeByte(index, offset, UInt32(newValue))
            #else
                unsafe base.storeBytes(of: newValue, toByteOffset: Int(offset), as: UInt8.self)
            #endif
        }
    }
}
