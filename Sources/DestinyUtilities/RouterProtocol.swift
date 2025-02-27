//
//  RouterProtocol.swift
//
//
//  Created by Evan Anderson on 11/9/24.
//

/// Core Router protocol that handles middleware, routes and router groups.
public protocol RouterProtocol : AnyObject, Sendable {
    /// All the dynamic middleware that is registered to this router. Ordered in descending order of importance.
    var dynamicMiddleware : [any DynamicMiddlewareProtocol] { get set }

    /// The router groups attached to this router.
    var routerGroups : [any RouterGroupProtocol] { get }

    /// The static responder responsible for a static route.
    /// 
    /// - Parameters:
    ///   - startLine: The request's HTTP start line.
    /// - Returns: The static responder responsible for the `startLine`.
    @inlinable func staticResponder(for startLine: DestinyRoutePathType) -> (any StaticRouteResponderProtocol)?

    /// The dynamic responder responsible for a dynamic route.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    @inlinable func dynamicResponder(for request: inout any RequestProtocol) -> (any DynamicRouteResponderProtocol)?

    /// The conditional responder responsible for a route.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    @inlinable func conditionalResponder(for request: inout any RequestProtocol) -> (any RouteResponderProtocol)?

    /// The error responder.
    @inlinable func errorResponder(for request: inout any RequestProtocol) -> any ErrorResponderProtocol

    /// The responder for requests to unregistered endpoints.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    @inlinable func notFoundResponse<C: SocketProtocol & ~Copyable>(socket: borrowing C, request: inout any RequestProtocol) async throws

    /// Registers a static route to this router.
    /// 
    /// - Parameters:
    ///   - route: The static route you want to register.
    ///   - override: Whether or not to replace the existing responder with the same endpoint.
    func register(_ route: any StaticRouteProtocol, override: Bool) throws

    /// Registers a dynamic route with its responder to this router.
    /// 
    /// - Parameters:
    ///   - route: The dynamic route you want to register.
    ///   - responder: The dynamic responder you want to register.
    ///   - override: Whether or not to replace the existing responder with the same endpoint.
    func register(_ route: any DynamicRouteProtocol, responder: any DynamicRouteResponderProtocol, override: Bool) throws

    /// Registers a static middleware at the given index to this router.
    func register(_ middleware: any StaticMiddlewareProtocol, at index: Int) throws

    /// Registers a dynamic middleware at the given index to this router.
    func register(_ middleware: any DynamicMiddlewareProtocol, at index: Int) throws


    /// Registers a static route with the GET HTTP method to this router.
    //func get(_ path: [String], responder: any RouteResponderProtocol) throws
}