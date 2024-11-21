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

    public private(set) var staticMiddleware:[StaticMiddlewareProtocol]
    public private(set) var dynamicMiddleware:[DynamicMiddlewareProtocol]
    
    public init(
        staticResponses: [DestinyRoutePathType:StaticRouteResponderProtocol],
        dynamicResponses: DynamicResponses,
        staticMiddleware: [StaticMiddlewareProtocol],
        dynamicMiddleware: [DynamicMiddlewareProtocol]
    ) {
        self.staticResponses = staticResponses
        self.dynamicMiddleware = dynamicMiddleware
        self.staticMiddleware = staticMiddleware
        self.dynamicResponses = dynamicResponses
    }

    @inlinable
    public func staticResponder(for startLine: DestinyRoutePathType) -> StaticRouteResponderProtocol? {
        return staticResponses[startLine]
    }
    @inlinable
    public func dynamicResponder(for request: inout Request) -> DynamicRouteResponderProtocol? {
        return dynamicResponses.responder(for: &request)
    }

    public mutating func register(_ route: StaticRouteProtocol) throws {
        guard let responder:StaticRouteResponderProtocol = try route.responder(middleware: staticMiddleware) else { return }
        var string:String = route.method.rawValue + " /" + route.path.joined(separator: "/") + " " + route.version.string
        let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
        staticResponses[buffer] = responder
    }
    public mutating func register(_ route: DynamicRouteProtocol, responder: DynamicRouteResponderProtocol) throws {
        var copy:DynamicRouteProtocol = route
        if copy.status == nil {
            copy.status = .notImplemented
        }
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