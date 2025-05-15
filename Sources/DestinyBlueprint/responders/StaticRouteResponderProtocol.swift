//
//  StaticRouteResponderProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

/// Core Static Route Responder protocol that handles requests to static routes.
public protocol StaticRouteResponderProtocol: RouteResponderProtocol {
    /// Writes a response to a socket.
    @inlinable
    func respond<Socket: SocketProtocol & ~Copyable>(to socket: borrowing Socket) async throws
}