//
//  Router.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import HTTPTypes

/// The core Router that powers how Destiny handles middleware and routes.
public struct Router : Sendable {
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

    public mutating func register(_ route: StaticRouteProtocol) throws {
        guard let responder:StaticRouteResponseProtocol = try route.responder(version: version, middleware: staticMiddleware) else { return }
        var string:String = route.method.rawValue + " /" + route.path.joined(separator: "/") + " " + version
        let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
        staticResponses[buffer] = responder
    }
    public mutating func register(_ route: DynamicRouteProtocol, responder: DynamicRouteResponseProtocol) {
        var copy:DynamicRouteProtocol = route
        if copy.status == nil {
            copy.status = .notImplemented
        }
        copy.applyStaticMiddleware(staticMiddleware)
        dynamicResponses.register(version: version, route: copy, responder: responder)
    }
    public mutating func register(_ middleware: StaticMiddlewareProtocol, at index: Int) {
        staticMiddleware.insert(middleware, at: index)
        // TODO: update existing routes?
    }
    public mutating func register(_ middleware: DynamicMiddlewareProtocol, at index: Int) {
        dynamicMiddleware.insert(middleware, at: index)
        // TODO: update existing routes?
    }
}