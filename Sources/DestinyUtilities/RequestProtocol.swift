//
//  RequestProtocol.swift
//
//
//  Created by Evan Anderson on 11/11/24.
//

import HTTPTypes

public protocol RequestProtocol : Sendable, ~Copyable {
    init?(tokens: [SIMD64<UInt8>])

    var startLine : DestinyRoutePathType { get }
    var method : HTTPRequest.Method? { mutating get }

    var path : [String] { mutating get }
    var headers : [String:String] { mutating get }
}