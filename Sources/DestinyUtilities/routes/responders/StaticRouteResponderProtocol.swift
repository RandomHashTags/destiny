//
//  StaticRouteResponderProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import DestinyBlueprint

/// Core Static Route Responder protocol that handles requests to static routes.
public protocol StaticRouteResponderProtocol : RouteResponderProtocol {
    /// Writes a response to a socket.
    @inlinable func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws
}