//
//  DynamicRouteResponderProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

/// Core Dynamic Route Responder protocol that handles requests to dynamic routes.
public protocol DynamicRouteResponderProtocol : RouteResponderProtocol {
    associatedtype ConcreteSocket:SocketProtocol

    /// Path of the route.
    var path : [PathComponent] { get }

    /// Indexes where parameters are location in the `path`.
    var parameterPathIndexes : [Int] { get }

    /// Default `DynamicResponseProtocol` value computed at compile time taking into account all static middleware.
    var defaultResponse : any DynamicResponseProtocol { get }

    /// Writes a response to the socket.
    @inlinable
    func respond(
        to socket: borrowing ConcreteSocket,
        request: inout ConcreteSocket.ConcreteRequest,
        response: inout any DynamicResponseProtocol
    ) async throws
}