//
//  RouterGroup.swift
//
//
//  Created by Evan Anderson on 12/27/24.
//

import DestinyUtilities
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: RouterGroup
/// The default Router Group that powers how Destiny handles grouped routes.
public struct RouterGroup : RouterGroupProtocol {
    public let endpoint:String
    public let staticRoutes:[StaticRouteProtocol]
    public let dynamicRoutes:[DynamicRouteProtocol]

    public let staticMiddleware:[StaticMiddlewareProtocol]
    public let dynamicMiddleware:[DynamicMiddlewareProtocol]

    public init(
        endpoint: String,
        staticMiddleware: [StaticMiddlewareProtocol] = [],
        dynamicMiddleware: [DynamicMiddlewareProtocol] = [],
        _ routes: RouteProtocol...
    ) {
        self.init(endpoint: endpoint, staticMiddleware: staticMiddleware, dynamicMiddleware: dynamicMiddleware, routes)
    }
    public init(
        endpoint: String,
        staticMiddleware: [StaticMiddlewareProtocol] = [],
        dynamicMiddleware: [DynamicMiddlewareProtocol] = [],
        _ routes: [RouteProtocol]
    ) {
        self.endpoint = endpoint
        self.staticMiddleware = staticMiddleware
        self.dynamicMiddleware = dynamicMiddleware
        var staticRoutes:[StaticRouteProtocol] = [], dynamicRoutes:[DynamicRouteProtocol] = []
        for route in routes {
            if let route:StaticRouteProtocol = route as? StaticRouteProtocol {
                staticRoutes.append(route)
            } else if let route:DynamicRouteProtocol = route as? DynamicRouteProtocol {
                dynamicRoutes.append(route)
            }
        }
        self.staticRoutes = staticRoutes
        self.dynamicRoutes = dynamicRoutes
    }
    public init(
        endpoint: String,
        staticMiddleware: [StaticMiddlewareProtocol],
        dynamicMiddleware: [DynamicMiddlewareProtocol],
        staticRoutes: [StaticRouteProtocol],
        dynamicRoutes: [DynamicRouteProtocol]
    ) {
        self.endpoint = endpoint
        self.staticMiddleware = staticMiddleware
        self.dynamicMiddleware = dynamicMiddleware
        let prefixEndpoints:[String] = endpoint.split(separator: "/").map({ String($0) })
        var updatedStaticRoutes:[StaticRouteProtocol] = []
        for var route in staticRoutes {
            route.path.insert(contentsOf: prefixEndpoints, at: 0)
            updatedStaticRoutes.append(route)
        }
        self.staticRoutes = updatedStaticRoutes
        self.dynamicRoutes = dynamicRoutes
    }

    public var debugDescription : String {
        var staticMiddlewareString:String = "[]"
        if !staticMiddleware.isEmpty {
            staticMiddlewareString.removeLast()
            staticMiddlewareString += "\n"
            staticMiddlewareString += staticMiddleware.map({ $0.debugDescription }).joined(separator: ",\n")
            staticMiddlewareString += "\n]"
        }
        var staticRoutesString:String = "[]"
        if !staticRoutes.isEmpty {
            staticRoutesString.removeLast()
            staticRoutesString += "\n"
            staticRoutesString += staticRoutes.map({ $0.debugDescription }).joined(separator: ",\n")
            staticRoutesString += "\n]"
        }
        var dynamicRoutesString:String = "[]"
        if !staticRoutes.isEmpty {
            dynamicRoutesString.removeLast()
            dynamicRoutesString += "\n"
            dynamicRoutesString += dynamicRoutes.map({ $0.debugDescription }).joined(separator: ",\n")
            dynamicRoutesString += "\n]"
        }
        return "RouterGroup(\nendpoint: \"\(endpoint)\",\nstaticMiddleware: \(staticMiddlewareString),\ndynamicMiddleware: [],\nstaticRoutes: \(staticRoutesString),\ndynamicRoutes: \(dynamicRoutesString))"
    }

    public func staticResponder(for startLine: DestinyRoutePathType) -> StaticRouteResponderProtocol? { return nil }
    public func dynamicResponder(for request: inout RequestProtocol) -> DynamicRouteResponderProtocol? { return nil }
}

// MARK: Parse
public extension RouterGroup {
    static func parse(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        staticMiddleware: [StaticMiddlewareProtocol],
        dynamicMiddleware: [DynamicMiddlewareProtocol],
        _ function: FunctionCallExprSyntax
    ) -> RouterGroupProtocol {
        var endpoint:String = ""
        var conditionalResponders:[DestinyRoutePathType:ConditionalRouteResponderProtocol] = [:]
        var staticMiddleware:[StaticMiddlewareProtocol] = staticMiddleware
        var dynamicMiddleware:[DynamicMiddlewareProtocol] = dynamicMiddleware
        var staticRoutes:[StaticRouteProtocol] = []
        var dynamicRoutes:[DynamicRouteProtocol] = []
        for argument in function.arguments {
            if let label:String = argument.label?.text {
                switch label {
                    case "endpoint":
                        endpoint = argument.expression.stringLiteral!.string
                    case "staticMiddleware":
                        for argument in argument.expression.array!.elements {
                            if let function:FunctionCallExprSyntax = argument.expression.functionCall {
                                staticMiddleware.append(StaticMiddleware.parse(function))
                            }
                        }
                    case "dynamicMiddleware":
                        for argument in argument.expression.array!.elements {
                            if let function:FunctionCallExprSyntax = argument.expression.functionCall {
                                dynamicMiddleware.append(DynamicMiddleware.parse(function))
                            }
                        }
                    default:
                        break
                }
            } else if let function:FunctionCallExprSyntax = argument.expression.functionCall {
                if let decl:String = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                    switch decl {
                        case "StaticRoute":
                            if let route:StaticRoute = StaticRoute.parse(context: context, version: version, function) {
                                staticRoutes.append(route)
                            }
                        case "DynamicRoute":
                            if let route:DynamicRoute = DynamicRoute.parse(context: context, version: version, middleware: staticMiddleware, function) {
                                dynamicRoutes.append(route)
                            }
                        default:
                            break
                    }
                }
            }
        }
        return CompiledRouterGroup(endpoint: endpoint, staticMiddleware: staticMiddleware, staticRoutes: staticRoutes, dynamicRoutes: dynamicRoutes)
    }
}