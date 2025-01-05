//
//  DynamicRouteResponderProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

/// Core Dynamic Route Responder protocol that handles requests to dynamic routes.
public protocol DynamicRouteResponderProtocol : RouteResponderProtocol {
    /// The path of the route.
    var path : [PathComponent] { get }

    /// The indexes where the parameters are location in the `path`.
    var parameterPathIndexes : [Int] { get }

    /// The default `DynamicResponseProtocol` value computed at compile time taking into account all static middleware.
    var defaultResponse : DynamicResponseProtocol { get }

    /// Writes a response to the socket.
    @inlinable func respond<S: SocketProtocol & ~Copyable>(to socket: borrowing S, request: inout RequestProtocol, response: inout DynamicResponseProtocol) async throws
}