//
//  HTTPVersion.swift
//
//
//  Created by Evan Anderson on 11/8/24.
//

public struct HTTPVersion : Sendable, ~Copyable {
    public let token:StackString8

    init(_ token: StackString8) {
        self.token = token
    }
    public init(_ path: DestinyRoutePathType) {
        token = path.lowHalf.lowHalf
    }
}

public extension HTTPVersion {
    private static func get(major: UInt8, minor: UInt8) -> HTTPVersion {
        var token:StackString8 = StackString8()
        token[0] = 72 // H
        token[1] = 84 // T
        token[2] = 84 // T
        token[3] = 80 // P
        token[4] = 47 // /
        token[5] = 48 + major // major
        token[6] = 46 // .
        token[7] = 48 + minor // minor
        return HTTPVersion(token)
    }

    static let v0_9:HTTPVersion = get(major: 0, minor: 9)
    static let v1_0:HTTPVersion = get(major: 1, minor: 0)
    static let v1_1:HTTPVersion = get(major: 1, minor: 1)
    static let v1_2:HTTPVersion = get(major: 1, minor: 2)
    static let v2_0:HTTPVersion = get(major: 2, minor: 0)
    static let v3_0:HTTPVersion = get(major: 3, minor: 0)
}