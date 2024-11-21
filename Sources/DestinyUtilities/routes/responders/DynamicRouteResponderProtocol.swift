//
//  DynamicRouteResponderProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

/// The core Dynamic Route Responder protocol that powers Destiny's responses of requests to dynamic routes.
public protocol DynamicRouteResponderProtocol : RouteResponderProtocol {
    /// The path of the route.
    var path : [PathComponent] { get }
    /// The indexes where the parameters are location in the `path`.
    var parameterPathIndexes : Set<Int> { get }
    /// The default `DynamicResponseProtocol` value computed at compile time taking into account all static middleware.
    var defaultResponse : DynamicResponseProtocol { get }

    @inlinable func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: inout Request, response: inout DynamicResponseProtocol) throws
    @inlinable func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: inout Request, response: inout DynamicResponseProtocol) async throws
}