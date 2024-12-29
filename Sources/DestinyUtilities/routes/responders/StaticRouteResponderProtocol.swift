//
//  StaticRouteResponderProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

/// The core Static Route Responder protocol that handles requests to static routes.
public protocol StaticRouteResponderProtocol : RouteResponderProtocol {
    /// Write a response to a socket.
    @inlinable func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws
}