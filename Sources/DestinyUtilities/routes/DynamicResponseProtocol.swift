//
//  DynamicResponseProtocol.swift
//
//
//  Created by Evan Anderson on 11/5/24.
//

/// Core Dynamic Response protocol that builds a HTTP Message to dynamic routes before sending it to the client.
public protocol DynamicResponseProtocol : Sendable, CustomDebugStringConvertible {
    /// Timestamps when request events happen.
    var timestamps : DynamicRequestTimestamps { get set }

    /// The response `HTTPVersion`.
    var version : HTTPVersion { get set }

    /// The response status.
    var status : HTTPResponseStatus { get set }

    /// The response headers.
    var headers : [String:String] { get set }

    /// The response cookies.
    var cookies : [any HTTPCookieProtocol] { get set }
    
    /// The response content.
    var result : RouteResult { get set }

    /// The parameters associated with the route. Updated upon requests.
    var parameters : [String] { get set }

    /// The complete HTTP Message that gets sent to the client.
    @inlinable func response() throws -> String
}