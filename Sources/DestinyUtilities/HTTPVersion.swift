//
//  HTTPVersion.swift
//
//
//  Created by Evan Anderson on 11/8/24.
//

import SwiftSyntax

public struct HTTPVersion : CustomStringConvertible, Hashable, Sendable {
    public static func == (left: Self, right: Self) -> Bool {
        return left.token == right.token
    }

    /// `SIMD8<UInt8>` representation of this HTTP Version.
    public let token:StackString8
    
    /// String representation of this HTTP Version (`HTTP/<major>.<minor>`).
    public let string:String

    package init(token: StackString8, string: String) {
        self.token = token
        self.string = string
    }
    public init(_ path: DestinyRoutePathType) {
        switch path.lowHalf.lowHalf.lowHalf {
        case Self.v0_9simd: self = .v0_9
        case Self.v1_0simd: self = .v1_0
        case Self.v1_1simd: self = .v1_1
        case Self.v1_2simd: self = .v1_2
        case Self.v2_0simd: self = .v2_0
        case Self.v3_0simd: self = .v3_0
        default: self = .v0_9
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(token)
    }

    public var description : String {
        switch token {
        case Self.v0_9simd: return ".v0_9"
        case Self.v1_0simd: return ".v1_0"
        case Self.v1_1simd: return ".v1_1"
        case Self.v1_2simd: return ".v1_2"
        case Self.v2_0simd: return ".v2_0"
        case Self.v3_0simd: return ".v3_0"
        default:
            return "HTTPVersion(token: \(token), string: \"\(string)\")"
        }
    }
}

public extension HTTPVersion {
    private static func get_simd(major: UInt8, minor: UInt8) -> StackString8 {
        var token:StackString8 = StackString8()
        token[0] = 72 // H
        token[1] = 84 // T
        token[2] = 84 // T
        token[3] = 80 // P
        token[4] = 47 // /
        token[5] = 48 + major // major
        token[6] = 46 // .
        token[7] = 48 + minor // minor
        return token
    }
    private static func get(major: UInt8, minor: UInt8) -> HTTPVersion {
        return HTTPVersion(token: get_simd(major: major, minor: minor), string: "HTTP/\(major).\(minor)")
    }

    static let v0_9:HTTPVersion = get(major: 0, minor: 9)
    static let v1_0:HTTPVersion = get(major: 1, minor: 0)
    static let v1_1:HTTPVersion = get(major: 1, minor: 1)
    static let v1_2:HTTPVersion = get(major: 1, minor: 2)
    static let v2_0:HTTPVersion = get(major: 2, minor: 0)
    static let v3_0:HTTPVersion = get(major: 3, minor: 0)

    static let v0_9simd:StackString8 = get_simd(major: 0, minor: 9)
    static let v1_0simd:StackString8 = get_simd(major: 1, minor: 0)
    static let v1_1simd:StackString8 = get_simd(major: 1, minor: 1)
    static let v1_2simd:StackString8 = get_simd(major: 1, minor: 2)
    static let v2_0simd:StackString8 = get_simd(major: 2, minor: 0)
    static let v3_0simd:StackString8 = get_simd(major: 3, minor: 0)
}

public extension HTTPVersion {
    static func parse(_ expr: ExprSyntax) -> HTTPVersion? {
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