//
//  StaticResponderStorage.swift
//
//
//  Created by Evan Anderson on 3/2/25.
//

public protocol StaticResponderStorageProtocol : Sendable {
    /// - Returns: Whether or not a responder was found for the `startLine`.
    @inlinable
    func respond<S: SocketProtocol>(
        to socket: S,
        with startLine: DestinyRoutePathType
    ) async throws -> Bool

    func exists(for path: DestinyRoutePathType) -> Bool
}