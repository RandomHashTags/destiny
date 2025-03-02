//
//  RouterProtocol.swift
//
//
//  Created by Evan Anderson on 11/9/24.
//

import Logging

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

    @inlinable
    func handleDynamicMiddleware(
        for request: inout ConcreteSocket.ConcreteRequest,
        with response: inout ConcreteDynamicResponse
    ) async throws

    /// Process an accepted file descriptor.
    @inlinable
    func process(
        client: Int32,
        received: ContinuousClock.Instant,
        socket: borrowing ConcreteSocket,
        logger: Logger
    ) async throws
}