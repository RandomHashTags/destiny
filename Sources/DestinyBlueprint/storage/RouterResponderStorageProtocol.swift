//
//  RouterResponderStorageProtocol.swift
//
//
//  Created by Evan Anderson on 4/18/25.
//

public protocol RouterResponderStorageProtocol: Sendable {
    @inlinable
    func respond<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout any RequestProtocol
    ) async throws -> Bool
}