//
//  RouteResponseProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import HTTPTypes

/// The core Route Responder Protocol that describes how to respond to requests.
public protocol RouteResponseProtocol : Sendable {
    /// Whether or not this `RouteResponseProtocol` responds asynchronously or synchronously.
    @inlinable var isAsync : Bool { get }
}

/// The core Static Route Responder Protocol that describes how to respond to requests at compile time.
public protocol StaticRouteResponseProtocol : RouteResponseProtocol {
    @inlinable func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws
    @inlinable func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws
}

/// The core Dynamic Route Responder Protocol that describes how to respond to dynamic requests.
public protocol DynamicRouteResponseProtocol : RouteResponseProtocol {
    var method : HTTPRequest.Method { get }
    var path: String { get }
    var version : String { get }
    var defaultResponse : DynamicResponse { get }

    @inlinable func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: borrowing Request, response: inout DynamicResponse) throws
    @inlinable func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: borrowing Request, response: inout DynamicResponse) async throws
}