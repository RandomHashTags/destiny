//
//  RouteResponseProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

public protocol RouteResponseProtocol : Sendable {
    /// Whether or not this `RouteResponseProtocol` responds asynchronously or by blocking.
    /// 
    /// - Warning: Does one or the other. Cannot do both.
    @inlinable var isAsync : Bool { get }
    @inlinable func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws
    @inlinable func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws
}