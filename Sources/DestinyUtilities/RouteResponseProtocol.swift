//
//  RouteResponseProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

// MARK: RouteResponse
public protocol RouteResponseProtocol : Sendable {
    @inlinable var isAsync : Bool { get }
    @inlinable func respond(to socket: borrowing any SocketProtocol & ~Copyable) throws
    @inlinable func respondAsync(to socket: borrowing any SocketProtocol & ~Copyable) async throws
}