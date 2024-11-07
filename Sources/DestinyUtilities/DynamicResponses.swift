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

    public subscript(_ token: DestinyRoutePathType) -> (HTTPStartLine, DynamicRouteResponseProtocol)? {
        let spaced:[DestinyRoutePathType] = token.splitSIMD(separator: 32) // 32 = space
        guard let version:String = spaced.get(2)?.string(), let method:HTTPRequest.Method = HTTPRequest.Method.parse(spaced[0].string()) else {
            return nil
        }
        let values:[String] = spaced[1].splitSIMD(separator: 47).map({ $0.string() }) // 1 = the target route path; 47 = slash
        if let responder:DynamicRouteResponseProtocol = parameterless[token] {
            return (HTTPStartLine(method: method, path: values, version: version), responder)
        }
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
                return (HTTPStartLine(method: method, path: values, version: version), route)
            }
        }
        return nil
    }
}