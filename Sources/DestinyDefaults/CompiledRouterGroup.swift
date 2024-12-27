//
//  CompiledRouterGroup.swift
//
//
//  Created by Evan Anderson on 12/27/24.
//

import DestinyUtilities
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: CompiledRouterGroup
public struct CompiledRouterGroup : RouterGroupProtocol {
    public let prefixEndpoints:[String]
    public let staticMiddleware:[StaticMiddlewareProtocol]
    public let dynamicMiddleware:[DynamicMiddlewareProtocol]
    public let staticResponses:[DestinyRoutePathType:StaticRouteResponderProtocol]
    public let dynamicResponses:DynamicResponses

    public init(
        endpoint: String,
        staticMiddleware: [StaticMiddlewareProtocol],
        dynamicMiddleware: [DynamicMiddlewareProtocol],
        staticRoutes: [StaticRouteProtocol],
        dynamicRoutes: [DynamicRouteProtocol]
    ) {
        let prefixEndpoints:[String] = endpoint.split(separator: "/").map({ String($0) })
        self.prefixEndpoints = prefixEndpoints
        self.staticMiddleware = staticMiddleware
        self.dynamicMiddleware = dynamicMiddleware
        var staticResponses:[DestinyRoutePathType:StaticRouteResponderProtocol] = [:]
        for var route in staticRoutes {
            route.path.insert(contentsOf: prefixEndpoints, at: 0)
            do {
                if let responder:StaticRouteResponderProtocol = try route.responder(middleware: staticMiddleware) {
                    let string:String = route.startLine
                    staticResponses[DestinyRoutePathType(string)] = responder
                }
            } catch {
                // TODO: do something
            }
        }

        let pathComponents:[PathComponent] = prefixEndpoints.map({ .literal($0) })
        var parameterless:[DestinyRoutePathType:DynamicRouteResponderProtocol] = [:]
        var parameterized:[[DynamicRouteResponderProtocol]] = []
        for var route in dynamicRoutes {
            route.path.insert(contentsOf: pathComponents, at: 0)
            let responder:DynamicRouteResponderProtocol = route.responder()
            if route.path.count(where: { $0.isParameter }) != 0 {
                if parameterized.count <= route.path.count {
                    for _ in 0...(route.path.count - parameterized.count) {
                        parameterized.append([])
                    }
                }
                parameterized[route.path.count].append(responder)
            } else {
                parameterless[DestinyRoutePathType(route.startLine)] = responder
            }
        }
        self.staticResponses = staticResponses
        self.dynamicResponses = .init(parameterless: parameterless, parameterized: parameterized)
    }
    public init(
        prefixEndpoints: [String],
        staticMiddleware: [StaticMiddlewareProtocol],
        dynamicMiddleware: [DynamicMiddlewareProtocol],
        staticResponses: [DestinyRoutePathType:StaticRouteResponderProtocol],
        dynamicResponses: DynamicResponses
    ) {
        self.prefixEndpoints = prefixEndpoints
        self.staticMiddleware = staticMiddleware
        self.dynamicMiddleware = dynamicMiddleware
        self.staticResponses = staticResponses
        self.dynamicResponses = dynamicResponses
    }

    public var debugDescription : String {
        var staticMiddlewareString:String = "[]"
        if !staticMiddleware.isEmpty {
            staticMiddlewareString.removeLast()
            staticMiddlewareString += "\n" + staticMiddleware.map({ $0.debugDescription }).joined(separator: ",\n") + "\n]"
        }
        var dynamicMiddlewareString:String = "[]"
        if !dynamicMiddleware.isEmpty {
            dynamicMiddlewareString.removeLast()
            dynamicMiddlewareString += "\n" + dynamicMiddleware.map({ $0.debugDescription }).joined(separator: ",\n") + "\n]"
        }
        var staticResponsesString:String = "[]"
        if !staticResponses.isEmpty {
            staticResponsesString.removeLast()
            staticResponsesString += "\n" + staticResponses.map({ "// \($0.key.stringSIMD())\n\($0.key) : " + $0.value.debugDescription }).joined(separator: ",\n") + "\n]"
        }
        return """
        CompiledRouterGroup(
            prefixEndpoints: \(prefixEndpoints),
            staticMiddleware: \(staticMiddlewareString),
            dynamicMiddleware: \(dynamicMiddlewareString),
            staticResponses: \(staticResponsesString),
            dynamicResponses: \(dynamicResponses.debugDescription)
        )
        """
    }

    @inlinable
    public func staticResponder(for startLine: DestinyRoutePathType) -> StaticRouteResponderProtocol? {
        return staticResponses[startLine]
    }

    @inlinable
    public func dynamicResponder(for request: inout RequestProtocol) -> DynamicRouteResponderProtocol? {
        return dynamicResponses.responder(for: &request)
    }
}

// MARK: Parse
public extension CompiledRouterGroup {
    static func parse(context: some MacroExpansionContext, version: HTTPVersion, staticMiddleware: [StaticMiddlewareProtocol], dynamicMiddleware: [DynamicMiddlewareProtocol], _ function: FunctionCallExprSyntax) -> RouterGroupProtocol {
        fatalError("don't use; never used; not yet implemented")
    }
}