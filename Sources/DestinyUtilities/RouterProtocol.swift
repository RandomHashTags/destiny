//
//  RouterProtocol.swift
//
//
//  Created by Evan Anderson on 11/9/24.
//

/// The core Router protocol that powers how Destiny handles middleware and routes.
public protocol RouterProtocol : Sendable, ~Copyable {
    /// All the dynamic middleware that is registered to this router. Ordered in descending order of importance.
    var dynamicMiddleware : [DynamicMiddlewareProtocol] { get }

    /// Get the static responder responsible for a static route based on its path.
    @inlinable func staticResponder(for startLine: DestinyRoutePathType) -> StaticRouteResponderProtocol?

    /// Gets the dynamic responder responsible for a dynamic route based on its path.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    @inlinable func dynamicResponder(for request: inout RequestProtocol) -> DynamicRouteResponderProtocol?

    /// Registers a static route to this router after the server has started.
    mutating func register(_ route: StaticRouteProtocol) throws

    /// Registers a dynamic route with its responder to this router after the server has started.
    mutating func register(_ route: DynamicRouteProtocol, responder: DynamicRouteResponderProtocol) throws

    /// Registers a static middleware at the given index to this router after the server has started.
    mutating func register(_ middleware: StaticMiddlewareProtocol, at index: Int) throws

    /// Registers a dynamic middleware at the given index to this router after the server has started.
    mutating func register(_ middleware: DynamicMiddlewareProtocol, at index: Int) throws
}