//
//  Router.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

public struct Router : Sendable {
    public let version:String
    public private(set) var staticResponses:[DestinyRoutePathType:StaticRouteResponseProtocol]
    public private(set) var dynamicResponses:DynamicResponses
    public private(set) var dynamicMiddleware:[DynamicMiddlewareProtocol]
    
    public init(
        version: String,
        staticResponses: [DestinyRoutePathType:StaticRouteResponseProtocol],
        dynamicResponses: DynamicResponses,
        dynamicMiddleware: [DynamicMiddlewareProtocol]
    ) {
        self.version = version
        self.staticResponses = staticResponses
        self.dynamicMiddleware = dynamicMiddleware
        self.dynamicResponses = dynamicResponses
    }

    public mutating func register(_ route: StaticRouteProtocol, responder: StaticRouteResponseProtocol) {
        var string:String = route.method.rawValue + " /" + route.path.joined(separator: "/") + " " + version
        let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
        staticResponses[buffer] = responder
    }
    public mutating func register(_ route: DynamicRouteProtocol, responder: DynamicRouteResponseProtocol) {
        dynamicResponses.register(version: version, route: route, responder: responder)
    }
    public mutating func register(_ middleware: DynamicMiddlewareProtocol, at index: Int) {
        dynamicMiddleware.insert(middleware, at: index)
    }
}