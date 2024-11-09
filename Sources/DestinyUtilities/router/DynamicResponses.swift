//
//  DynamicResponses.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import HTTPTypes

public struct DynamicResponses : Sendable {
    public private(set) var parameterless:[DestinyRoutePathType:DynamicRouteResponseProtocol]
    public private(set) var parameterized:[[DynamicRouteResponseProtocol]]

    public init(
        parameterless: [DestinyRoutePathType:DynamicRouteResponseProtocol],
        parameterized: [[DynamicRouteResponseProtocol]]
    ) {
        self.parameterless = parameterless
        self.parameterized = parameterized
    }

    mutating func register(version: String, route: DynamicRouteProtocol, responder: DynamicRouteResponseProtocol) {
        if route.path.count(where: { $0.isParameter }) == 0 {
            var string:String = route.method.rawValue + " /" + route.path.map({ $0.slug }).joined(separator: "/") + " " + version
            let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
            parameterless[buffer] = responder
        } else {
            if parameterized.count <= route.path.count {
                for _ in parameterized.count...route.path.count {
                    parameterized.append([])
                }
            }
            parameterized[route.path.count].append(responder)
        }
    }

    public func responder(for request: inout Request) -> DynamicRouteResponseProtocol? {
        if let responder:DynamicRouteResponseProtocol = parameterless[request.startLine] {
            return responder
        }
        let values:[String] = request.path
        guard let routes:[DynamicRouteResponseProtocol] = parameterized.get(values.count) else { return nil }
        for route in routes {
            var found:Bool = true
            for i in 0..<values.count {
                let path:PathComponent = route.path[i]
                if !path.isParameter && path.value != values[i] {
                    found = false
                    break
                }
            }
            if found {
                return route
            }
        }
        return nil
    }
}