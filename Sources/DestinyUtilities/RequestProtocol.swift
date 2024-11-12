//
//  RequestProtocol.swift
//
//
//  Created by Evan Anderson on 11/11/24.
//

public protocol RequestProtocol : Sendable, ~Copyable {
    var startLine : DestinyRoutePathType { get }

    init?(tokens: [SIMD64<UInt8>])

    var path : [String] { mutating get }
}