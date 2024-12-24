//
//  StaticRouteResponderProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

/// The core Static Route Responder protocol that powers Destiny's responses of requests to static routes.
public protocol StaticRouteResponderProtocol : RouteResponderProtocol {
    /// Write a response synchronously to a socket.
    @inlinable func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws

    /// Write a response asynchronously to a socket.
    @inlinable func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws
}