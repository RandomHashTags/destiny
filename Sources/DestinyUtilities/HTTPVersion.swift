//
//  HTTPVersion.swift
//
//
//  Created by Evan Anderson on 11/8/24.
//

import SwiftSyntax

/// An HTTP version.
public enum HTTPVersion : String, Hashable, Sendable {
    case v0_9
    case v1_0
    case v1_1
    case v1_2
    case v2_0
    case v3_0

    @inlinable
    public init(token: SIMD8<UInt8>) {
        switch token {
        case SIMD8(72, 84, 84, 80, 47, 48, 46, 57): self = .v0_9 // HTTP/0.9
        case SIMD8(72, 84, 84, 80, 47, 49, 46, 48): self = .v1_0 // HTTP/1.0
        case SIMD8(72, 84, 84, 80, 47, 49, 46, 49): self = .v1_1 // HTTP/1.1
        case SIMD8(72, 84, 84, 80, 47, 49, 46, 50): self = .v1_2 // HTTP/1.2
        case SIMD8(72, 84, 84, 80, 47, 50, 46, 48): self = .v2_0 // HTTP/2.0
        case SIMD8(72, 84, 84, 80, 47, 51, 46, 48): self = .v3_0 // HTTP/3.0
        default:                                    self = .v1_1
        }
    }

    @inlinable
    public init(_ path: DestinyRoutePathType) {
        self.init(token: path.lowHalf.lowHalf.lowHalf)
    }

    /// String representation of this HTTP Version (`HTTP/<major>.<minor>`).
    @inlinable
    public func string() -> String {
        switch self {
        case .v0_9: return "HTTP/0.9"
        case .v1_0: return "HTTP/1.0"
        case .v1_1: return "HTTP/1.1"
        case .v1_2: return "HTTP/1.2"
        case .v2_0: return "HTTP/2.0"
        case .v3_0: return "HTTP/3.0"
        }
    }

    /// `SIMD8<UInt8>` representation of this HTTP Version.
    @inlinable
    public var simd : SIMD8<UInt8> {
        switch self {
        case .v0_9: return SIMD8(72, 84, 84, 80, 47, 48, 46, 57) // HTTP/0.9
        case .v1_0: return SIMD8(72, 84, 84, 80, 47, 49, 46, 48) // HTTP/1.0
        case .v1_1: return SIMD8(72, 84, 84, 80, 47, 49, 46, 49) // HTTP/1.1
        case .v1_2: return SIMD8(72, 84, 84, 80, 47, 49, 46, 50) // HTTP/1.2
        case .v2_0: return SIMD8(72, 84, 84, 80, 47, 50, 46, 48) // HTTP/2.0
        case .v3_0: return SIMD8(72, 84, 84, 80, 47, 51, 46, 48) // HTTP/3.0
        }
    }
}

extension HTTPVersion {
    public static func parse(_ expr: ExprSyntax) -> HTTPVersion? {
        guard let string:String = expr.memberAccess?.declName.baseName.text else { return nil }
        switch string {
        case "v0_9": return .v0_9
        case "v1_0": return .v1_0
        case "v1_1": return .v1_1
        case "v1_2": return .v1_2
        case "v2_0": return .v2_0
        case "v3_0": return .v3_0
        default: return nil
        }
    }
}