//
//  StaticResponderStorage.swift
//
//
//  Created by Evan Anderson on 3/2/25.
//

public protocol StaticResponderStorageProtocol: Sendable {
    /// - Returns: Whether or not a responder was found for the `startLine`.
    @inlinable
    func respond<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        socket: borrowing Socket,
        startLine: SIMD64<UInt8>
    ) async throws -> Bool
}