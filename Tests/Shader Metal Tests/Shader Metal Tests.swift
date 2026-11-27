#if canImport(Metal)
    import Shader
    import Cardinal
    import Metal
    @testable import Shader_Metal
    import Testing

    enum `Shader Metal Tests` {}

    extension `Shader Metal Tests` {
        @Suite
        struct Pool {
            @Test func `a buffer is made at a power of two up to a mebibyte and in whole mebibytes above`() {
                #expect(Shader.Metal.Pool.size(1) == 256)
                #expect(Shader.Metal.Pool.size(257) == 512)
                #expect(Shader.Metal.Pool.size(1_048_576) == 1_048_576)
                #expect(Shader.Metal.Pool.size(1_048_577) == 2_097_152)
            }

            @Test func `a kept buffer is taken for a size it holds at no more than twice its size`() {
                #expect(Shader.Metal.Pool.fitting(512, among: [256, 1024, 2048]) == 1024)
                #expect(Shader.Metal.Pool.fitting(512, among: [2048]) == nil)
            }

            @Test func `a full pool lets go of what was given longest ago`() throws {
                let device = try #require(MTLCreateSystemDefaultDevice())
                var pool = Shader.Metal.Pool(bound: 3_145_728)
                for mebibytes in [1, 2, 1] {
                    let buffer = try #require(device.makeBuffer(length: mebibytes << 20, options: .storageModeShared))
                    pool.give(Shader.Metal.Pool.Sheet(buffer: buffer))
                }
                #expect(pool.bytes == 3 << 20)
                #expect(pool.buffers[1 << 20]?.map(\.given) == [3])
                #expect(pool.buffers[2 << 20]?.map(\.given) == [2])
            }
        }

        @Suite
        struct Timing {
            @Test func `timing counts each kernel's runs and seconds, the longest first`() {
                let timing = Shader.Metal.Timing()
                timing.record("paint", seconds: 0.5)
                timing.record("copy", seconds: 0.25)
                timing.record("paint", seconds: 1)
                #expect(timing.entries == [.init(name: "paint", count: 2, seconds: 1.5), .init(name: "copy", count: 1, seconds: 0.25)])
                #expect(timing.report.contains("paint\t2\t1.500\t750.000\t85.7%"))
            }
        }
    }
#endif
