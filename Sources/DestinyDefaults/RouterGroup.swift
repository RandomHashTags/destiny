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
/// Default Router Group implementation that handles grouped routes.
public struct RouterGroup : RouterGroupProtocol { // TODO: use `StaticResponderStorage`
    public typealias ConcreteDynamicRouteResponder = DynamicRouteResponder

    public let prefixEndpoints:[String]
    public let staticMiddleware:[StaticMiddleware]
    public let dynamicMiddleware:[DynamicMiddleware]
    public let staticResponses:[DestinyRoutePathType:any StaticRouteResponderProtocol]
    public let dynamicResponses:DynamicResponderStorage

    public init(
        endpoint: String,
        staticMiddleware: [StaticMiddleware] = [],
        dynamicMiddleware: [DynamicMiddleware] = [],
        _ routes: any RouteProtocol...
    ) {
        var staticRoutes:[StaticRoute] = []
        var dynamicRoutes:[DynamicRoute] = []
        for route in routes {
            if let route:StaticRoute = route as? StaticRoute {
                staticRoutes.append(route)
            } else if let route:DynamicRoute = route as? DynamicRoute {
                dynamicRoutes.append(route)
            }
        }
        self.init(endpoint: endpoint, staticMiddleware: staticMiddleware, dynamicMiddleware: dynamicMiddleware, staticRoutes: staticRoutes, dynamicRoutes: dynamicRoutes)
    }
    public init(
        endpoint: String,
        staticMiddleware: [StaticMiddleware],
        dynamicMiddleware: [DynamicMiddleware],
        staticRoutes: [StaticRoute],
        dynamicRoutes: [DynamicRoute]
    ) {
        let prefixEndpoints:[String] = endpoint.split(separator: "/").map({ String($0) })
        self.prefixEndpoints = prefixEndpoints
        self.staticMiddleware = staticMiddleware
        self.dynamicMiddleware = dynamicMiddleware
        var staticResponses:[DestinyRoutePathType:any StaticRouteResponderProtocol] = [:]
        for var route in staticRoutes {
            route.path.insert(contentsOf: prefixEndpoints, at: 0)
            do {
                if let responder:any StaticRouteResponderProtocol = try route.responder(context: nil, function: nil, middleware: staticMiddleware) {
                    let string:String = route.startLine
                    staticResponses[DestinyRoutePathType(string)] = responder
                }
            } catch {
                // TODO: do something
            }
        }

        let pathComponents:[PathComponent] = prefixEndpoints.map({ .literal($0) })
        var parameterless:[DestinyRoutePathType:DynamicRouteResponder] = [:]
        var parameterized:[[DynamicRouteResponder]] = []
        for var route in dynamicRoutes {
            route.path.insert(contentsOf: pathComponents, at: 0)
            let responder:DynamicRouteResponder = route.responder()
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
        self.dynamicResponses = .init(parameterless: parameterless, parameterized: parameterized, catchall: []) // TODO: fix catchall
    }
    public init(
        prefixEndpoints: [String],
        staticMiddleware: [StaticMiddleware],
        dynamicMiddleware: [DynamicMiddleware],
        staticResponses: [DestinyRoutePathType:any StaticRouteResponderProtocol],
        dynamicResponses: DynamicResponderStorage
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
        RouterGroup(
            prefixEndpoints: \(prefixEndpoints),
            staticMiddleware: \(staticMiddlewareString),
            dynamicMiddleware: \(dynamicMiddlewareString),
            staticResponses: \(staticResponsesString),
            dynamicResponses: \(dynamicResponses.debugDescription)
        )
        """
    }

    @inlinable
    public func staticResponder(for startLine: DestinyRoutePathType) -> (any StaticRouteResponderProtocol)? {
        return staticResponses[startLine]
    }

    @inlinable
    public func dynamicResponder(for request: inout ConcreteDynamicRouteResponder.ConcreteSocket.ConcreteRequest) -> ConcreteDynamicRouteResponder? {
        return dynamicResponses.responder(for: &request)
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension RouterGroup {
    public static func parse(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        staticMiddleware: [any StaticMiddlewareProtocol],
        dynamicMiddleware: [any DynamicMiddlewareProtocol],
        _ function: FunctionCallExprSyntax
    ) -> Self {
        var endpoint:String = ""
        var conditionalResponders:[DestinyRoutePathType:any ConditionalRouteResponderProtocol] = [:]
        var staticMiddleware:[StaticMiddleware] = staticMiddleware.compactMap({ $0 as? StaticMiddleware }) // TODO: fix
        var dynamicMiddleware:[DynamicMiddleware] = dynamicMiddleware.compactMap({ $0 as? DynamicMiddleware }) // TODO: fix
        var staticRoutes:[StaticRoute] = []
        var dynamicRoutes:[DynamicRoute] = []
        for argument in function.arguments {
            if let label:String = argument.label?.text {
                switch label {
                case "endpoint":
                    endpoint = argument.expression.stringLiteral!.string
                case "staticMiddleware":
                    for argument in argument.expression.array!.elements {
                        if let function:FunctionCallExprSyntax = argument.expression.functionCall {
                            staticMiddleware.append(StaticMiddleware.parse(context: context, function))
                        }
                    }
                case "dynamicMiddleware":
                    for argument in argument.expression.array!.elements {
                        if let function:FunctionCallExprSyntax = argument.expression.functionCall {
                            dynamicMiddleware.append(DynamicMiddleware.parse(context: context, function))
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
        return Self(endpoint: endpoint, staticMiddleware: staticMiddleware, dynamicMiddleware: dynamicMiddleware, staticRoutes: staticRoutes, dynamicRoutes: dynamicRoutes)
    }
}
#endif