//
//  ConditionalRouteResponderProtocol.swift
//
//
//  Created by Evan Anderson on 12/24/24.
//

/// Core Conditional Route Responder protocol that selects a route responder based on a request.
public protocol ConditionalRouteResponderProtocol: CustomDebugStringConvertible, RouteResponderProtocol {
    /// - Parameters:
    ///   - socket: The socket.
    ///   - request: The request.
    /// - Returns: Whether or not a route responder responded to the request.
    @inlinable
    func respond<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout any RequestProtocol
    ) async throws -> Bool
}