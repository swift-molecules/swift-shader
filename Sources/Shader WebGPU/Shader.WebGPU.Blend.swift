public import Shader

extension Shader.WebGPU {
    /// How a stage's colour meets what its target holds: for the colours and for the alpha, each the stage's value
    /// times one factor, and the target's times another, added, subtracted, or the lesser or greater of the two.
    public struct Blend: Sendable, Hashable {
        public var color: Part
        public var alpha: Part

        public init(color: Part, alpha: Part) {
            self.color = color
            self.alpha = alpha
        }

        /// The same for the colours and the alpha.
        public init(_ operation: Operation = .add, source: Factor, target: Factor) {
            color = Part(operation, source: source, target: target)
            alpha = color
        }
    }
}

extension Shader.WebGPU.Blend {
    public struct Part: Sendable, Hashable {
        public var operation: Operation
        public var source: Factor
        public var target: Factor

        public init(_ operation: Operation = .add, source: Factor, target: Factor) {
            self.operation = operation
            self.source = source
            self.target = target
        }
    }

    /// What is done with the two products. The lesser and the greater take the values themselves, with both factors
    /// one.
    public enum Operation: Int32, Sendable, Hashable, CaseIterable {
        case add = 0
        case subtract = 1
        case reverse = 2
        case least = 3
        case most = 4
    }

    /// What a value is multiplied by.
    public enum Factor: Int32, Sendable, Hashable, CaseIterable {
        case zero = 0
        case one = 1
        case source = 2
        case sourceLeft = 3
        case sourceAlpha = 4
        case sourceAlphaLeft = 5
        case target = 6
        case targetLeft = 7
        case targetAlpha = 8
        case targetAlphaLeft = 9
    }

    /// The stage's colour takes the target's place.
    public static let replace = Self(source: .one, target: .zero)

    /// The stage's colour, already multiplied by its alpha, over the target's.
    public static let over = Self(source: .one, target: .sourceAlphaLeft)

    /// The stage's colour added to the target's.
    public static let sum = Self(source: .one, target: .one)

    /// The greater of the stage's colour and the target's.
    public static let most = Self(.most, source: .one, target: .one)
}
