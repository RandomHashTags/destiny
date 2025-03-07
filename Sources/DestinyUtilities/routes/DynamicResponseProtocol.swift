//
//  DynamicResponseProtocol.swift
//
//
//  Created by Evan Anderson on 11/5/24.
//

/// Core Dynamic Response protocol that builds a HTTP Message to dynamic routes before sending it to the client.
public protocol DynamicResponseProtocol : Sendable, CustomDebugStringConvertible {
    associatedtype ConcreteHTTPMessage:HTTPMessageProtocol

    /// Timestamps when request events happen.
    var timestamps : DynamicRequestTimestamps { get set }

    var message : ConcreteHTTPMessage { get set }

    /// The parameters associated with the route. Updated upon requests.
    var parameters : [String] { get set }
}