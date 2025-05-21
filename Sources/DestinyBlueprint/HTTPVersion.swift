
import SwiftSyntax

/// List of Hypertext Transfer Protocol versions.
public enum HTTPVersion: String, Hashable, Sendable {
    case v0_9
    case v1_0
    case v1_1
    case v1_2
    case v2_0
    case v3_0

    @inlinable
    public init?(token: SIMD8<UInt8>) {
        switch token {
        case SIMD8(72, 84, 84, 80, 47, 48, 46, 57): self = .v0_9 // HTTP/0.9
        case SIMD8(72, 84, 84, 80, 47, 49, 46, 48): self = .v1_0 // HTTP/1.0
        case SIMD8(72, 84, 84, 80, 47, 49, 46, 49): self = .v1_1 // HTTP/1.1
        case SIMD8(72, 84, 84, 80, 47, 49, 46, 50): self = .v1_2 // HTTP/1.2
        case SIMD8(72, 84, 84, 80, 47, 50, 46, 48): self = .v2_0 // HTTP/2.0
        case SIMD8(72, 84, 84, 80, 47, 51, 46, 48): self = .v3_0 // HTTP/3.0
        default:                                    return nil
        }
    }

    @inlinable
    public init?(token: InlineArray<8, UInt8>) {
        switch token {
        case #inlineArray("HTTP/0.9"): self = .v0_9
        case #inlineArray("HTTP/1.0"): self = .v1_0
        case #inlineArray("HTTP/1.1"): self = .v1_1
        case #inlineArray("HTTP/1.2"): self = .v1_2
        case #inlineArray("HTTP/2.0"): self = .v2_0
        case #inlineArray("HTTP/3.0"): self = .v3_0
        default: return nil
        }
    }

    @inlinable
    public init?(_ path: SIMD64<UInt8>) {
        self.init(token: path.lowHalf.lowHalf.lowHalf)
    }

    /// String representation of this HTTP Version (`HTTP/<major>.<minor>`).
    @inlinable
    public var string: String {
        switch self {
        case .v0_9: "HTTP/0.9"
        case .v1_0: "HTTP/1.0"
        case .v1_1: "HTTP/1.1"
        case .v1_2: "HTTP/1.2"
        case .v2_0: "HTTP/2.0"
        case .v3_0: "HTTP/3.0"
        }
    }

    /// `SIMD8<UInt8>` representation of this HTTP Version.
    @inlinable
    public var simd: SIMD8<UInt8> {
        switch self {
        case .v0_9: SIMD8(72, 84, 84, 80, 47, 48, 46, 57) // HTTP/0.9
        case .v1_0: SIMD8(72, 84, 84, 80, 47, 49, 46, 48) // HTTP/1.0
        case .v1_1: SIMD8(72, 84, 84, 80, 47, 49, 46, 49) // HTTP/1.1
        case .v1_2: SIMD8(72, 84, 84, 80, 47, 49, 46, 50) // HTTP/1.2
        case .v2_0: SIMD8(72, 84, 84, 80, 47, 50, 46, 48) // HTTP/2.0
        case .v3_0: SIMD8(72, 84, 84, 80, 47, 51, 46, 48) // HTTP/3.0
        }
    }

    /// `InlineArray<8, UInt8>` representation of this HTTP Version.
    @inlinable
    public var inlineArray: InlineArray<8, UInt8> {
        switch self {
        case .v0_9: #inlineArray("HTTP/0.9")
        case .v1_0: #inlineArray("HTTP/1.0")
        case .v1_1: #inlineArray("HTTP/1.1")
        case .v1_2: #inlineArray("HTTP/1.2")
        case .v2_0: #inlineArray("HTTP/2.0")
        case .v3_0: #inlineArray("HTTP/3.0")
        }
    }
}

#if canImport(SwiftSyntax)
// MARK: SwiftSyntax
extension HTTPVersion {
    public static func parse(_ expr: ExprSyntax) -> HTTPVersion? {
        switch expr.as(MemberAccessExprSyntax.self)?.declName.baseName.text {
        case "v0_9": .v0_9
        case "v1_0": .v1_0
        case "v1_1": .v1_1
        case "v1_2": .v1_2
        case "v2_0": .v2_0
        case "v3_0": .v3_0
        default:     nil
        }
    }
}
#endif