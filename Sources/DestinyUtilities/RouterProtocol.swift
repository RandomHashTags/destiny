//
//  RouterProtocol.swift
//
//
//  Created by Evan Anderson on 11/9/24.
//

import DestinyBlueprint
import Logging

/// Core Router protocol that handles middleware, routes and router groups.
public protocol RouterProtocol : AnyObject, Sendable {
    @inlinable func loadDynamicMiddleware()

    @inlinable
    func handleDynamicMiddleware(
        for request: inout any RequestProtocol,
        with response: inout any DynamicResponseProtocol
    ) async throws

    /// Process an accepted file descriptor.
    @inlinable
    func process<Socket: SocketProtocol & ~Copyable>(
        client: Int32,
        received: ContinuousClock.Instant,
        socket: borrowing Socket,
        logger: Logger
    ) async throws
}