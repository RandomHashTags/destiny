//
//  StaticResponderStorage.swift
//
//
//  Created by Evan Anderson on 3/2/25.
//

public protocol StaticResponderStorageProtocol: Sendable {
    /// - Returns: Whether or not a responder was found for the `startLine`.
    @inlinable
    func respond<Socket: SocketProtocol & ~Copyable>(
        to socket: borrowing Socket,
        with startLine: SIMD64<UInt8>
    ) async throws -> Bool
}