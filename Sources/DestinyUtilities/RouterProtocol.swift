//
//  RouterProtocol.swift
//
//
//  Created by Evan Anderson on 11/9/24.
//

/// Core Router protocol that handles middleware, routes and router groups.
public protocol RouterProtocol : Sendable, ~Copyable {
    /// All the dynamic middleware that is registered to this router. Ordered in descending order of importance.
    var dynamicMiddleware : [DynamicMiddlewareProtocol] { get set }

    /// The router groups attached to this router.
    var routerGroups : [RouterGroupProtocol] { get }

    /// The static responder responsible for a static route.
    /// 
    /// - Parameters:
    ///   - startLine: The request's HTTP start line.
    /// - Returns: The static responder responsible for the `startLine`.
    @inlinable func staticResponder(for startLine: DestinyRoutePathType) -> StaticRouteResponderProtocol?

    /// The dynamic responder responsible for a dynamic route.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    @inlinable func dynamicResponder(for request: inout RequestProtocol) -> DynamicRouteResponderProtocol?

    /// The conditional responder responsible for a route.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    @inlinable func conditionalResponder(for request: inout RequestProtocol) -> RouteResponderProtocol?

    /// The error responder.
    @inlinable func errorResponder(for request: inout RequestProtocol) -> ErrorResponderProtocol

    /// The responder for requests to unregistered endpoints.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    @inlinable func notFoundResponse<C: SocketProtocol & ~Copyable>(socket: borrowing C, request: inout RequestProtocol) async throws

    /// Registers a static route to this router.
    /// 
    /// - Parameters:
    ///   - route: The static route you want to register.
    ///   - override: Whether or not to replace the existing responder with the same endpoint.
    mutating func register(_ route: StaticRouteProtocol, override: Bool) throws

    /// Registers a dynamic route with its responder to this router.
    /// 
    /// - Parameters:
    ///   - route: The dynamic route you want to register.
    ///   - responder: The dynamic responder you want to register.
    ///   - override: Whether or not to replace the existing responder with the same endpoint.
    mutating func register(_ route: DynamicRouteProtocol, responder: DynamicRouteResponderProtocol, override: Bool) throws

    /// Registers a static middleware at the given index to this router.
    mutating func register(_ middleware: StaticMiddlewareProtocol, at index: Int) throws

    /// Registers a dynamic middleware at the given index to this router.
    mutating func register(_ middleware: DynamicMiddlewareProtocol, at index: Int) throws


    /// Registers a static route with the GET HTTP method to this router.
    //mutating func get(_ path: [String], responder: RouteResponderProtocol) throws
}