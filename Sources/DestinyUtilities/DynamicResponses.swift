//
//  DynamicResponses.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

public struct DynamicResponses : Sendable {
    public let parameterless:[DestinyRoutePathType:DynamicRouteResponseProtocol]
    public let parameterized:[DynamicRouteProtocol]
    public let parameterizedResponses:[DynamicRouteResponseProtocol]

    public init(
        parameterless: [DestinyRoutePathType:DynamicRouteResponseProtocol],
        parameterized: [DynamicRouteProtocol],
        parameterizedResponses: [DynamicRouteResponseProtocol]
    ) {
        self.parameterless = parameterless
        self.parameterized = parameterized
        self.parameterizedResponses = parameterizedResponses
    }

    public subscript(_ token: DestinyRoutePathType) -> ([String], DynamicRouteProtocol?, DynamicRouteResponseProtocol)? {
        if let responder:DynamicRouteResponseProtocol = parameterless[token] {
            return (responder.path, nil, responder)
        }
        let values:[String] = token.splitSIMD(separator: 32)[1].splitSIMD(separator: 47).map({ $0.string() }) // 32 = space; 1 = the target route path; 47 = slash
        for (index, route) in parameterized.enumerated() {
            if route.path.count == values.count {
                var found:Bool = true
                for i in 0..<values.count {
                    let path:PathComponent = route.path[i]
                    if !path.isParameter && path.value != values[i] {
                        found = false
                        break
                    }
                }
                if found {
                    return (values, route, parameterizedResponses[index])
                }
            }
        }
        return nil
    }
}