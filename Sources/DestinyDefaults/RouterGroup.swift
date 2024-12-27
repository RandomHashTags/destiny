//
//  RouterGroup.swift
//
//
//  Created by Evan Anderson on 12/27/24.
//

import DestinyUtilities

public struct RouterGroup : RouterGroupProtocol {
    public private(set) var staticResponses:[DestinyRoutePathType:StaticRouteResponderProtocol]
    public private(set) var dynamicResponses:DynamicResponses
    public private(set) var conditionalResponses:[DestinyRoutePathType:ConditionalRouteResponderProtocol]

    public private(set) var staticMiddleware:[StaticMiddlewareProtocol]
    public private(set) var dynamicMiddleware:[DynamicMiddlewareProtocol]

    public init(
        endpoint: String,
        staticRoutes: [StaticRouteProtocol] = [],
        dynamicRoutes: [DynamicRouteProtocol] = [],
        conditionalResponders: [DestinyRoutePathType:ConditionalRouteResponderProtocol] = [:],
        staticMiddleware: [StaticMiddlewareProtocol] = [],
        dynamicMiddleware: [DynamicMiddlewareProtocol] = []
    ) throws {
        let prefixEndpoints:[String] = endpoint.split(separator: "/").map({ String($0) })
        var updatedStaticResponders:[DestinyRoutePathType:StaticRouteResponderProtocol] = [:]
        for var route in staticRoutes {
            if let responder:StaticRouteResponderProtocol = try route.responder(middleware: staticMiddleware) {
                route.path.insert(contentsOf: prefixEndpoints, at: 0)
                updatedStaticResponders[DestinyRoutePathType.init(route.path.joined(separator: "/"))] = responder
            }
        }
        self.staticResponses = updatedStaticResponders

        var parameterless:[DestinyRoutePathType:DynamicRouteResponderProtocol] = [:]
        var parameterized:[[any DynamicRouteResponderProtocol]] = []
        if !dynamicRoutes.isEmpty {
            let prefixPathComponentEndpoints:[PathComponent] = prefixEndpoints.map({ .literal($0) })
            for var route in dynamicRoutes {
                route.path.insert(contentsOf: prefixPathComponentEndpoints, at: 0)
                if route.path.first(where: { $0.isParameter }) == nil {
                } else {
                }
            }
        }
        self.dynamicResponses = .init(parameterless: parameterless, parameterized: parameterized)

        self.conditionalResponses = conditionalResponders
        self.staticMiddleware = staticMiddleware
        self.dynamicMiddleware = dynamicMiddleware
    }

    @inlinable
    public func responder(for request: inout RequestProtocol) -> RouteResponderProtocol? {
        if let responder:StaticRouteResponderProtocol = staticResponses[request.startLine] {
            return responder
        } else if let responder:DynamicRouteResponderProtocol = dynamicResponses.responder(for: &request) {
            return responder
        } else if let responder:ConditionalRouteResponderProtocol = conditionalResponses[request.startLine] {
            return responder
        }
        return nil
    }
}