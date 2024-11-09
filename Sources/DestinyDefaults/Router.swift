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
    public let version:String
    public private(set) var staticResponses:[DestinyRoutePathType:StaticRouteResponseProtocol]
    public private(set) var dynamicResponses:DynamicResponses

    public private(set) var staticMiddleware:[StaticMiddlewareProtocol]
    public private(set) var dynamicMiddleware:[DynamicMiddlewareProtocol]
    
    public init(
        version: String,
        staticResponses: [DestinyRoutePathType:StaticRouteResponseProtocol],
        dynamicResponses: DynamicResponses,
        staticMiddleware: [StaticMiddlewareProtocol],
        dynamicMiddleware: [DynamicMiddlewareProtocol]
    ) {
        self.version = version
        self.staticResponses = staticResponses
        self.dynamicMiddleware = dynamicMiddleware
        self.staticMiddleware = staticMiddleware
        self.dynamicResponses = dynamicResponses
    }

    @inlinable
    public func staticResponder(for startLine: DestinyRoutePathType) -> StaticRouteResponseProtocol? {
        return staticResponses[startLine]
    }
    @inlinable
    public func dynamicResponder(for request: inout Request) -> DynamicRouteResponseProtocol? {
        return dynamicResponses.responder(for: &request)
    }

    public mutating func register(_ route: StaticRouteProtocol) throws {
        guard let responder:StaticRouteResponseProtocol = try route.responder(version: version, middleware: staticMiddleware) else { return }
        var string:String = route.method.rawValue + " /" + route.path.joined(separator: "/") + " " + version
        let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
        staticResponses[buffer] = responder
    }
    public mutating func register(_ route: DynamicRouteProtocol, responder: DynamicRouteResponseProtocol) throws {
        var copy:DynamicRouteProtocol = route
        if copy.status == nil {
            copy.status = .notImplemented
        }
        copy.applyStaticMiddleware(staticMiddleware)
        dynamicResponses.register(version: version, route: copy, responder: responder)
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