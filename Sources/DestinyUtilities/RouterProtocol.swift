//
//  RouterProtocol.swift
//
//
//  Created by Evan Anderson on 11/9/24.
//

/// Core Router protocol that handles middleware, routes and router groups.
public protocol RouterProtocol : AnyObject, Sendable {
    associatedtype ConcreteSocket:SocketProtocol

    associatedtype ConcreteStaticRoute:StaticRouteProtocol
    associatedtype ConcreteDynamicRoute:DynamicRouteProtocol

    associatedtype ConcreteStaticMiddleware:StaticMiddlewareProtocol

    associatedtype ConcreteDynamicMiddleware:DynamicMiddlewareProtocol where
        ConcreteSocket.ConcreteRequest == ConcreteDynamicMiddleware.ConcreteRequest,
        ConcreteDynamicMiddleware.ConcreteResponse == ConcreteDynamicResponse
    associatedtype ConcreteDynamicResponse:DynamicResponseProtocol
    associatedtype ConcreteDynamicRouteResponder:DynamicRouteResponderProtocol where
        ConcreteSocket == ConcreteDynamicRouteResponder.ConcreteSocket,
        ConcreteDynamicRouteResponder.ConcreteResponse == ConcreteDynamicResponse

    associatedtype ConcreteErrorResponder:ErrorResponderProtocol // TODO: make `ConcreteStaticErrorResponder` and add `ConcreteDynamicErrorResponder`

    associatedtype ConcreteRouterGroup:RouterGroupProtocol where
        ConcreteSocket == ConcreteRouterGroup.ConcreteDynamicRouteResponder.ConcreteSocket,
        ConcreteDynamicRouteResponder == ConcreteRouterGroup.ConcreteDynamicRouteResponder

    /// The router groups attached to this router.
    var routerGroups : [ConcreteRouterGroup] { get }
    
    @inlinable func loadDynamicMiddleware()

    @inlinable func handleDynamicMiddleware(
        for request: inout ConcreteSocket.ConcreteRequest,
        with response: inout ConcreteDynamicResponse
    ) async throws

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
    @inlinable func dynamicResponder(for request: inout ConcreteSocket.ConcreteRequest) -> ConcreteDynamicRouteResponder?

    /// The conditional responder responsible for a route.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    @inlinable func conditionalResponder(for request: inout ConcreteSocket.ConcreteRequest) -> (any RouteResponderProtocol)?

    /// The error responder.
    @inlinable func errorResponder(for request: inout ConcreteSocket.ConcreteRequest) -> ConcreteErrorResponder

    /// The responder for requests to unregistered endpoints.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    @inlinable func notFoundResponse(
        socket: borrowing ConcreteSocket,
        request: inout ConcreteSocket.ConcreteRequest
    ) async throws

    /// Registers a static route to this router.
    /// 
    /// - Parameters:
    ///   - route: The static route you want to register.
    ///   - override: Whether or not to replace the existing responder with the same endpoint.
    func register(_ route: ConcreteStaticRoute, override: Bool) throws

    /// Registers a dynamic route with its responder to this router.
    /// 
    /// - Parameters:
    ///   - route: The dynamic route you want to register.
    ///   - responder: The dynamic responder you want to register.
    ///   - override: Whether or not to replace the existing responder with the same endpoint.
    func register(_ route: ConcreteDynamicRoute, responder: ConcreteDynamicRouteResponder, override: Bool) throws

    /// Registers a static middleware at the given index to this router.
    func register(_ middleware: ConcreteStaticMiddleware, at index: Int) throws

    /// Registers a dynamic middleware at the given index to this router.
    func register(_ middleware: ConcreteDynamicMiddleware, at index: Int) throws


    /// Registers a static route with the GET HTTP method to this router.
    //func get(_ path: [String], responder: any RouteResponderProtocol) throws
}