//
//  DynamicResponseProtocol.swift
//
//
//  Created by Evan Anderson on 11/5/24.
//

import HTTPTypes

/// The core Dynamic Response protocol that powers how Destiny manages a dynamic response to dynamic routes.
public protocol DynamicResponseProtocol : Sendable, CustomDebugStringConvertible {
    /// The response status.
    var status : HTTPResponse.Status { get set }
    /// The response headers.
    var headers : [String:String] { get set }
    /// The response content.
    var result : RouteResult { get set }

    /// The complete HTTP Response to send to the client.
    /// - Parameters:
    ///   - version: The HTTP version associated with the route.
    @inlinable func response(version: String) throws -> String
}