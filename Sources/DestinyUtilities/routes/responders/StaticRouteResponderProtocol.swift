//
//  StaticRouteResponderProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

/// The core Static Route Responder protocol that powers Destiny's responses of requests to static routes.
public protocol StaticRouteResponderProtocol : RouteResponderProtocol {
    @inlinable func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws
    @inlinable func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws
}