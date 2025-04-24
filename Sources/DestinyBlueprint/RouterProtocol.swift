//
//  RouterProtocol.swift
//
//
//  Created by Evan Anderson on 11/9/24.
//

import Logging

/// Core Router protocol that handles middleware, routes and router groups.
public protocol RouterProtocol: AnyObject, Sendable {
    @inlinable func loadDynamicMiddleware()

    /// Process an accepted file descriptor.
    @inlinable
    func process<Socket: SocketProtocol & ~Copyable>(
        client: Int32,
        received: ContinuousClock.Instant,
        socket: borrowing Socket,
        logger: Logger
    ) async throws
}