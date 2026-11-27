public import Shader
import Synchronization

#if canImport(Metal)
    public import Metal
#endif

extension Shader.Metal {
    /// How long the GPU spent in each kernel, from the GPU's start and end of the commands that ran it alone. A
    /// renderer that is given one sends each kernel in commands of its own and waits for them, so it is for
    /// measuring, not for drawing films.
    public final class Timing: Sendable {
        private let kept = Mutex<[Swift.String: Shader.Metal.Timing.Entry]>([:])

        public init() {}
    }
}

extension Shader.Metal.Timing {
    /// Counts one run of a kernel that took `seconds` of the GPU.
    public func record(_ name: Swift.String, seconds: Double) {
        kept.withLock { entries in
            entries[name, default: Shader.Metal.Timing.Entry(name: name)].count += 1
            entries[name, default: Shader.Metal.Timing.Entry(name: name)].seconds += seconds
        }
    }

    /// Every kernel run, the one that took longest in all first.
    public var entries: [Shader.Metal.Timing.Entry] {
        kept.withLock { $0.values.sorted { $0.seconds > $1.seconds } }
    }

    /// The entries as a table: kernel, runs, GPU seconds in all, milliseconds a run and share of the whole.
    public var report: Swift.String {
        let entries = entries
        let whole = entries.reduce(0) { $0 + $1.seconds }
        var text = "kernel\truns\tseconds\tms a run\tshare\n"
        for entry in entries {
            let each = entry.count > 0 ? 1000 * entry.seconds / Double(entry.count) : 0
            let share = whole > 0 ? 100 * entry.seconds / whole : 0
            text += "\(entry.name)\t\(entry.count)\t\(Self.fixed(entry.seconds, 3))\t\(Self.fixed(each, 3))\t\(Self.fixed(share, 1))%\n"
        }
        return text
    }

    static func fixed(_ value: Double, _ places: Int) -> Swift.String {
        var scale = 1.0
        for _ in 0..<places { scale *= 10 }
        let whole = (value * scale).rounded()
        let integer = Int(whole / scale)
        let fraction = Int(abs(whole) - abs(Double(integer)) * scale)
        guard places > 0 else { return "\(integer)" }
        let digits = Swift.String(fraction)
        return "\(integer).\(Swift.String(repeating: "0", count: Swift.max(places - digits.count, 0)))\(digits)"
    }
}

#if canImport(Metal)
    extension Shader.Metal.Timing {
        /// Counts the commands' GPU time against the kernel named by `name` once they complete; to be called before
        /// they are sent.
        public func record(_ name: Swift.String, of commands: any MTLCommandBuffer) {
            commands.addCompletedHandler { [self] done in
                guard done.status == .completed else { return }
                record(name, seconds: done.gpuEndTime - done.gpuStartTime)
            }
        }
    }
#endif
