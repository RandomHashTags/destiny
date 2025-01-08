//
//  Router.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import DestinyUtilities

/// Default Router that handles middleware, routes and router groups.
public final class Router : RouterProtocol {
    public let version:HTTPVersion
    public private(set) var staticResponses:[DestinyRoutePathType:StaticRouteResponderProtocol]
    public private(set) var dynamicResponses:DynamicResponses
    public private(set) var conditionalResponses:[DestinyRoutePathType:ConditionalRouteResponderProtocol]

    public private(set) var staticMiddleware:[StaticMiddlewareProtocol]
    public var dynamicMiddleware:[DynamicMiddlewareProtocol]

    public private(set) var routerGroups:[RouterGroupProtocol]
    
    public var errorResponder:ErrorResponderProtocol
    public var dynamicNotFoundResponder:DynamicRouteResponderProtocol?
    public var staticNotFoundResponder:StaticRouteResponderProtocol
    
    public init(
        version: HTTPVersion,
        errorResponder: ErrorResponderProtocol,
        dynamicNotFoundResponder: DynamicRouteResponderProtocol? = nil,
        staticNotFoundResponder: StaticRouteResponderProtocol,
        staticResponses: [DestinyRoutePathType:StaticRouteResponderProtocol],
        dynamicResponses: DynamicResponses,
        conditionalResponses: [DestinyRoutePathType:ConditionalRouteResponderProtocol],
        staticMiddleware: [StaticMiddlewareProtocol],
        dynamicMiddleware: [DynamicMiddlewareProtocol],
        routerGroups: [RouterGroupProtocol]
    ) {
        self.version = version
        self.errorResponder = errorResponder
        self.dynamicNotFoundResponder = dynamicNotFoundResponder
        self.staticNotFoundResponder = staticNotFoundResponder
        self.staticResponses = staticResponses
        self.dynamicMiddleware = dynamicMiddleware
        self.conditionalResponses = conditionalResponses
        self.staticMiddleware = staticMiddleware
        self.dynamicResponses = dynamicResponses
        self.routerGroups = routerGroups
    }

    @inlinable
    public func staticResponder(for startLine: DestinyRoutePathType) -> StaticRouteResponderProtocol? {
        return staticResponses[startLine]
    }
    @inlinable
    public func dynamicResponder(for request: inout RequestProtocol) -> DynamicRouteResponderProtocol? {
        return dynamicResponses.responder(for: &request)
    }
    
    @inlinable
    public func conditionalResponder(for request: inout RequestProtocol) -> RouteResponderProtocol? {
        return conditionalResponses[request.startLine]?.responder(for: &request)
    }

    @inlinable
    public func routerGroupStaticResponder(for startLine: DestinyRoutePathType) -> StaticRouteResponderProtocol? {
        for group in routerGroups {
            if let responder:StaticRouteResponderProtocol = group.staticResponder(for: startLine) {
                return responder
            }
        }
        return nil
    }

    @inlinable
    public func routerGroupDynamicResponder(for request: inout RequestProtocol) -> DynamicRouteResponderProtocol? {
        for group in routerGroups {
            if let responder:DynamicRouteResponderProtocol = group.dynamicResponder(for: &request) {
                return responder
            }
        }
        return nil
    }

    @inlinable
    public func errorResponder(for request: inout RequestProtocol) -> ErrorResponderProtocol {
        return errorResponder
    }

    @inlinable
    public func notFoundResponse<C: SocketProtocol & ~Copyable>(socket: borrowing C, request: inout RequestProtocol) async throws {
        if let responder:DynamicRouteResponderProtocol = dynamicNotFoundResponder { // TODO: support
            //try await responder.respond(to: socket, request: &request, response: &any DynamicResponseProtocol)
        } else {
            try await staticNotFoundResponder.respond(to: socket)
        }
    }

    public func register(_ route: StaticRouteProtocol, override: Bool = false) throws {
        guard let responder:StaticRouteResponderProtocol = try route.responder(context: nil, function: nil, middleware: staticMiddleware) else { return }
        var string:String = route.startLine
        let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
        if override || staticResponses[buffer] == nil {
            staticResponses[buffer] = responder
        } else {
            // TODO: throw error
        }
    }
    public func register(_ route: DynamicRouteProtocol, responder: DynamicRouteResponderProtocol, override: Bool = false) throws {
        var copy:DynamicRouteProtocol = route
        copy.applyStaticMiddleware(staticMiddleware)
        try dynamicResponses.register(version: copy.version, route: copy, responder: responder, override: override)
    }
    public func register(_ middleware: StaticMiddlewareProtocol, at index: Int) throws {
        staticMiddleware.insert(middleware, at: index)
        // TODO: update existing routes?
    }
    public func register(_ middleware: DynamicMiddlewareProtocol, at index: Int) throws {
        dynamicMiddleware.insert(middleware, at: index)
        // TODO: update existing routes?
    }
}