//
//  Router.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import DestinyUtilities
import HTTPTypes

/// The default Router implementation that powers how Destiny handles middleware and routes.
public struct Router : RouterProtocol {
    public private(set) var staticResponses:[DestinyRoutePathType:StaticRouteResponderProtocol]
    public private(set) var dynamicResponses:DynamicResponses
    public private(set) var conditionalResponses:[DestinyRoutePathType:ConditionalRouteResponderProtocol]

    public private(set) var staticMiddleware:[StaticMiddlewareProtocol]
    public private(set) var dynamicMiddleware:[DynamicMiddlewareProtocol]

    public private(set) var routerGroups:[RouterGroupProtocol]
    
    public init(
        staticResponses: [DestinyRoutePathType:StaticRouteResponderProtocol],
        dynamicResponses: DynamicResponses,
        conditionalResponses: [DestinyRoutePathType:ConditionalRouteResponderProtocol],
        staticMiddleware: [StaticMiddlewareProtocol],
        dynamicMiddleware: [DynamicMiddlewareProtocol],
        routerGroups: [RouterGroupProtocol]
    ) {
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

    public mutating func register(_ route: StaticRouteProtocol) throws {
        guard let responder:StaticRouteResponderProtocol = try route.responder(middleware: staticMiddleware) else { return }
        var string:String = route.method.rawValue + " /" + route.path.joined(separator: "/") + " " + route.version.string
        let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
        staticResponses[buffer] = responder
    }
    public mutating func register(_ route: DynamicRouteProtocol, responder: DynamicRouteResponderProtocol) throws {
        var copy:DynamicRouteProtocol = route
        copy.applyStaticMiddleware(staticMiddleware)
        dynamicResponses.register(version: copy.version, route: copy, responder: responder)
    }
    public mutating func register(_ middleware: StaticMiddlewareProtocol, at index: Int) throws {
        staticMiddleware.insert(middleware, at: index)
        // TODO: update existing routes?
    }
    public mutating func register(_ middleware: DynamicMiddlewareProtocol, at index: Int) throws {
        dynamicMiddleware.insert(middleware, at: index)
        // TODO: update existing routes?
    }
}