//
//  DynamicRouteResponderProtocol.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

/// Core Dynamic Route Responder protocol that handles requests to dynamic routes.
public protocol DynamicRouteResponderProtocol: RouteResponderProtocol {

    /// Yields the path of the route.
    @inlinable
    func forEachPathComponent(_ yield: (PathComponent) -> Void)

    func pathComponent(at index: Int) -> PathComponent
    var pathComponentsCount: Int { get }

    /// Yields the index where parameters are location in the path.
    @inlinable
    func forEachPathComponentParameterIndex(_ yield: (Int) -> Void)

    /// Default `DynamicResponseProtocol` value computed at compile time taking into account all static middleware.
    var defaultResponse: any DynamicResponseProtocol { get }

    /// Writes a response to the socket.
    @inlinable
    func respond<Socket: SocketProtocol & ~Copyable>(
        to socket: borrowing Socket,
        request: inout any RequestProtocol,
        response: inout any DynamicResponseProtocol
    ) async throws
}