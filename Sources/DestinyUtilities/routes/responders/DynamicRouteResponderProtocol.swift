//
//  DynamicRouteResponderProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import DestinyBlueprint

/// Core Dynamic Route Responder protocol that handles requests to dynamic routes.
public protocol DynamicRouteResponderProtocol : RouteResponderProtocol {
    /// Path of the route.
    var path : [PathComponent] { get }

    /// Indexes where parameters are location in the `path`.
    var parameterPathIndexes : [Int] { get }

    /// Default `DynamicResponseProtocol` value computed at compile time taking into account all static middleware.
    var defaultResponse : any DynamicResponseProtocol { get }

    /// Writes a response to the socket.
    @inlinable
    func respond<S: SocketProtocol & ~Copyable>(
        to socket: borrowing S,
        request: inout any RequestProtocol,
        response: inout any DynamicResponseProtocol
    ) async throws
}