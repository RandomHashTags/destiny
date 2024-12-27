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
    public let staticResponses:[DestinyRoutePathType:StaticRouteResponderProtocol]
    public let dynamicResponses:DynamicResponses

    public init(
        endpoint: String,
        staticMiddleware: [StaticMiddlewareProtocol],
        staticRoutes: [StaticRouteProtocol],
        dynamicRoutes: [DynamicRouteProtocol]
    ) {
        let prefixEndpoints:[String] = endpoint.split(separator: "/").map({ String($0) })
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
        var parameterless:[DestinyRoutePathType:DynamicRouteResponderProtocol] = [:]
        var parameterized:[[DynamicRouteResponderProtocol]] = []
        self.staticResponses = staticResponses
        self.dynamicResponses = .init(parameterless: parameterless, parameterized: parameterized)
    }
    public init(
        staticResponses: [DestinyRoutePathType:StaticRouteResponderProtocol],
        dynamicResponses: DynamicResponses
    ) {
        self.staticResponses = staticResponses
        self.dynamicResponses = dynamicResponses
    }

    public var debugDescription : String {
        var staticResponsesString:String = "[]"
        if !staticResponses.isEmpty {
            staticResponsesString.removeLast()
            staticResponsesString += "\n" + staticResponses.map({ "// \($0.key.stringSIMD())\n\($0.key) : " + $0.value.debugDescription }).joined(separator: ",\n") + "\n]"
        }
        return """
            CompiledRouterGroup(
                staticResponses: \(staticResponsesString),
                dynamicResponses: .init(parameterless: [:], parameterized: [])
            )
        """
    }

    @inlinable
    public func responder(for request: inout RequestProtocol) -> RouteResponderProtocol? {
        return staticResponses[request.startLine] ?? dynamicResponses.responder(for: &request)
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