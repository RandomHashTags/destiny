//
//  RouterGroup.swift
//
//
//  Created by Evan Anderson on 12/27/24.
//

#if canImport(DestinyUtilities)
import DestinyUtilities
#endif

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros
#endif

// MARK: RouterGroup
/// Default Router Group implementation that handles grouped routes.
public struct RouterGroup : RouterGroupProtocol {
    public let prefixEndpoints:[String]
    public let staticMiddleware:[StaticMiddlewareProtocol]
    public let dynamicMiddleware:[DynamicMiddlewareProtocol]
    public let staticResponses:[DestinyRoutePathType:StaticRouteResponderProtocol]
    public let dynamicResponses:DynamicResponses

    public init(
        endpoint: String,
        staticMiddleware: [StaticMiddlewareProtocol] = [],
        dynamicMiddleware: [DynamicMiddlewareProtocol] = [],
        _ routes: RouteProtocol...
    ) {
        var staticRoutes:[StaticRouteProtocol] = []
        var dynamicRoutes:[DynamicRouteProtocol] = []
        for route in routes {
            if let route:StaticRouteProtocol = route as? StaticRouteProtocol {
                staticRoutes.append(route)
            } else if let route:DynamicRouteProtocol = route as? DynamicRouteProtocol {
                dynamicRoutes.append(route)
            }
        }
        self.init(endpoint: endpoint, staticMiddleware: staticMiddleware, dynamicMiddleware: dynamicMiddleware, staticRoutes: staticRoutes, dynamicRoutes: dynamicRoutes)
    }
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
                if let responder:StaticRouteResponderProtocol = try route.responder(context: nil, function: nil, middleware: staticMiddleware) {
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
    public func staticResponder(for startLine: DestinyRoutePathType) -> StaticRouteResponderProtocol? {
        return staticResponses[startLine]
    }

    @inlinable
    public func dynamicResponder(for request: inout RequestProtocol) -> DynamicRouteResponderProtocol? {
        return dynamicResponses.responder(for: &request)
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension RouterGroup {
    public static func parse(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        staticMiddleware: [StaticMiddlewareProtocol],
        dynamicMiddleware: [DynamicMiddlewareProtocol],
        _ function: FunctionCallExprSyntax
    ) -> Self {
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