//
//  DynamicResponseProtocol.swift
//
//
//  Created by Evan Anderson on 11/5/24.
//

import HTTPTypes

/// The core Dynamic Response protocol that powers how Destiny manages a HTTP Response to dynamic routes before sending it to the client.
public protocol DynamicResponseProtocol : Sendable, CustomDebugStringConvertible {
    /// The response HTTP version.
    var version : HTTPVersion { get set }
    /// The response status.
    var status : HTTPResponse.Status { get set }
    /// The response headers.
    var headers : [String:String] { get set }
    /// The response content.
    var result : RouteResult { get set }

    /// The parameters associated with the route, that get updated upon requests.
    var parameters : [String:String] { get set }

    /// The complete HTTP Response that gets sent to the client.
    @inlinable func response() throws -> String
}