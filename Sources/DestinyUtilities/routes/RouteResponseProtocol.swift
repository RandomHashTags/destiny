//
//  RouteResponseProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import HTTPTypes

/// The core Route Response protocol that powers Destiny's route responses.
public protocol RouteResponseProtocol : Sendable {
    /// Whether or not this `RouteResponseProtocol` responds asynchronously or synchronously.
    @inlinable var isAsync : Bool { get }
}

/// The core Static Route Response protocol that powers Destiny's responses of requests to static routes.
public protocol StaticRouteResponseProtocol : RouteResponseProtocol {
    @inlinable func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws
    @inlinable func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws
}

/// The core Dynamic Route Response protocol that powers Destiny's responses of requests to dynamic routes.
public protocol DynamicRouteResponseProtocol : RouteResponseProtocol {
    /// The path of the route.
    var path : [PathComponent] { get }
    /// The indexes where the parameters are location in the `path`.
    var parameterPathIndexes : Set<Int> { get }
    /// The default `DynamicResponseProtocol` value computed at compile time taking into account all static middleware.
    var defaultResponse : DynamicResponseProtocol { get }
    /// The synchronous work to execute upon requests. Should be called from `respond`.
    var logic : (@Sendable (inout Request, inout DynamicResponseProtocol) throws -> Void)? { get }
    /// The asynchronous work to execute upon requests. Should be called from `respondAsync`.
    var logicAsync : (@Sendable (inout Request, inout DynamicResponseProtocol) async throws -> Void)? { get }

    @inlinable func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: inout Request, response: inout DynamicResponseProtocol) throws
    @inlinable func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: inout Request, response: inout DynamicResponseProtocol) async throws
}