//
//  RequestProtocol.swift
//
//
//  Created by Evan Anderson on 11/11/24.
//

import HTTPTypes

/// The core Request protocol that lays out how a socket's incoming data is parsed.
public protocol RequestProtocol : Sendable, ~Copyable {
    init?(tokens: [SIMD64<UInt8>])

    /// The HTTP start-line.
    var startLine : DestinyRoutePathType { get }
    /// The request method.
    var method : HTTPRequest.Method? { mutating get }

    /// The endpoint the request wants to reach, separated by the forward slash character.
    var path : [String] { mutating get }
    /// The request headers.
    var headers : [String:String] { mutating get }
}