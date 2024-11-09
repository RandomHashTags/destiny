//
//  RouterProtocol.swift
//
//
//  Created by Evan Anderson on 11/9/24.
//

/// The core Router protocol that powers how Destiny handles middleware and routes.
public protocol RouterProtocol : Sendable {

    /// All the dynamic middleware that is registered to this router. Ordered in descending order of importance.
    var dynamicMiddleware : [DynamicMiddlewareProtocol] { get }

    /// Gets the static responder.
    @inlinable func staticResponder(for startLine: DestinyRoutePathType) -> StaticRouteResponseProtocol?
    /// Gets the dynamic responder.
    @inlinable func dynamicResponder(for request: inout Request) -> DynamicRouteResponseProtocol?

    /// Registers a static route to this router after the server has started.
    mutating func register(_ route: StaticRouteProtocol) throws

    /// Registers a dynamic route with its responder to this router after the server has started.
    mutating func register(_ route: DynamicRouteProtocol, responder: DynamicRouteResponseProtocol) throws

    /// Registers a static middleware at the given index to this router after the server has started.
    mutating func register(_ middleware: StaticMiddlewareProtocol, at index: Int) throws

    /// Registers a dynamic middleware at the given index to this router after the server has started.
    mutating func register(_ middleware: DynamicMiddlewareProtocol, at index: Int) throws
}