//
//  RouteResponseProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import HTTPTypes

/// The core Route Responder protocol that powers Destiny's route responses.
public protocol RouteResponseProtocol : Sendable {
    /// Whether or not this `RouteResponseProtocol` responds asynchronously or synchronously.
    @inlinable var isAsync : Bool { get }
}

/// The core Static Route Responder protocol that responds to requests to static routes at compile time.
public protocol StaticRouteResponseProtocol : RouteResponseProtocol {
    @inlinable func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws
    @inlinable func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws
}

/// The core Dynamic Route Responder protocol that responds to requests dynamically.
public protocol DynamicRouteResponseProtocol : RouteResponseProtocol {
    var version : String { get }
    var method : HTTPRequest.Method { get }
    var path: [String] { get }
    var defaultResponse : DynamicResponse { get }

    @inlinable func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: borrowing Request, response: inout DynamicResponse) throws
    @inlinable func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: borrowing Request, response: inout DynamicResponse) async throws
}