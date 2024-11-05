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
    var version : String { get }
    var method : HTTPRequest.Method { get }
    var path: [String] { get }
    var defaultResponse : DynamicResponseProtocol { get }

    @inlinable func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: borrowing Request, response: inout DynamicResponseProtocol) throws
    @inlinable func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: borrowing Request, response: inout DynamicResponseProtocol) async throws
}