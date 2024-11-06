//
//  DynamicResponses.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

public struct DynamicResponses : Sendable {
    public private(set) var parameterless:[DestinyRoutePathType:DynamicRouteResponseProtocol]
    public private(set) var parameterized:[DynamicRouteProtocol]
    public private(set) var parameterizedResponses:[DynamicRouteResponseProtocol]

    public init(
        parameterless: [DestinyRoutePathType:DynamicRouteResponseProtocol],
        parameterized: [DynamicRouteProtocol],
        parameterizedResponses: [DynamicRouteResponseProtocol]
    ) {
        self.parameterless = parameterless
        self.parameterized = parameterized
        self.parameterizedResponses = parameterizedResponses
    }

    mutating func register(version: String, route: DynamicRouteProtocol, responder: DynamicRouteResponseProtocol) {
        if route.path.count(where: { $0.isParameter }) == 0 {
            var string:String = route.method.rawValue + " /" + route.path.map({ $0.slug }).joined(separator: "/") + " " + version
            let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
            parameterless[buffer] = responder
        } else {
            parameterized.append(route)
            parameterizedResponses.append(responder)
        }
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