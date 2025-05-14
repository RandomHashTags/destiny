//
//  RouterGroup.swift
//
//
//  Created by Evan Anderson on 12/27/24.
//

import DestinyBlueprint
import DestinyUtilities
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: RouterGroup
/// Default Router Group implementation that handles grouped routes.
public struct RouterGroup: RouterGroupProtocol {
    public let prefixEndpoints:[String]
    public let staticMiddleware:[any StaticMiddlewareProtocol]
    public let dynamicMiddleware:[any DynamicMiddlewareProtocol]
    public let staticResponses:[DestinyRoutePathType:any StaticRouteResponderProtocol]
    public let dynamicResponses:DynamicResponderStorage

    public init(
        endpoint: String,
        staticMiddleware: [any StaticMiddlewareProtocol] = [],
        dynamicMiddleware: [any DynamicMiddlewareProtocol] = [],
        _ routes: any RouteProtocol...
    ) {
        var staticRoutes:[any StaticRouteProtocol] = []
        var dynamicRoutes:[any DynamicRouteProtocol] = []
        for route in routes {
            if let route = route as? any StaticRouteProtocol {
                staticRoutes.append(route)
            } else if let route = route as? any DynamicRouteProtocol {
                dynamicRoutes.append(route)
            }
        }
        self.init(endpoint: endpoint, staticMiddleware: staticMiddleware, dynamicMiddleware: dynamicMiddleware, staticRoutes: staticRoutes, dynamicRoutes: dynamicRoutes)
    }
    public init(
        endpoint: String,
        staticMiddleware: [any StaticMiddlewareProtocol],
        dynamicMiddleware: [any DynamicMiddlewareProtocol],
        staticRoutes: [any StaticRouteProtocol],
        dynamicRoutes: [any DynamicRouteProtocol]
    ) {
        let prefixEndpoints = endpoint.split(separator: "/").map({ String($0) })
        self.prefixEndpoints = prefixEndpoints
        self.staticMiddleware = staticMiddleware
        self.dynamicMiddleware = dynamicMiddleware
        var staticResponses:[DestinyRoutePathType:any StaticRouteResponderProtocol] = [:]
        for var route in staticRoutes {
            route.path.insert(contentsOf: prefixEndpoints, at: 0)
            do {
                if let responder = try route.responder(context: nil, function: nil, middleware: staticMiddleware) {
                    let string = route.startLine
                    staticResponses[DestinyRoutePathType(string)] = responder
                }
            } catch {
                // TODO: do something
            }
        }

        let pathComponents:[PathComponent] = prefixEndpoints.map({ .literal($0) })
        var parameterless:[DestinyRoutePathType:any DynamicRouteResponderProtocol] = [:]
        var parameterized:[[any DynamicRouteResponderProtocol]] = []
        for var route in dynamicRoutes {
            route.path.insert(contentsOf: pathComponents, at: 0)
            let responder = route.responder()
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
        staticMiddleware: [any StaticMiddlewareProtocol],
        dynamicMiddleware: [any DynamicMiddlewareProtocol],
        staticResponses: [DestinyRoutePathType:any StaticRouteResponderProtocol],
        dynamicResponses: DynamicResponderStorage
    ) {
        self.prefixEndpoints = prefixEndpoints
        self.staticMiddleware = staticMiddleware
        self.dynamicMiddleware = dynamicMiddleware
        self.staticResponses = staticResponses
        self.dynamicResponses = dynamicResponses
    }

    public var debugDescription: String {
        var staticMiddlewareString = "[]"
        if !staticMiddleware.isEmpty {
            staticMiddlewareString.removeLast()
            staticMiddlewareString += "\n" + staticMiddleware.map({ $0.debugDescription }).joined(separator: ",\n") + "\n]"
        }
        var dynamicMiddlewareString = "[]"
        if !dynamicMiddleware.isEmpty {
            dynamicMiddlewareString.removeLast()
            dynamicMiddlewareString += "\n" + dynamicMiddleware.map({ $0.debugDescription }).joined(separator: ",\n") + "\n]"
        }
        var staticResponsesString = "[]"
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
}

// MARK: Respond
extension RouterGroup {
    @inlinable
    public func respond<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout any RequestProtocol
    ) async throws -> Bool {
        if let responder = staticResponses[request.startLine] {
            try await router.respondStatically(socket: socket, responder: responder)
            return true
        } else if let responder = dynamicResponses.responder(for: &request) {
            try await router.respondDynamically(received: received, loaded: loaded, socket: socket, request: &request, responder: responder)
            return true
        } else {
            return false
        }
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
        var endpoint = ""
        var conditionalResponders:[DestinyRoutePathType:any ConditionalRouteResponderProtocol] = [:]
        var staticMiddleware = staticMiddleware
        var dynamicMiddleware = dynamicMiddleware
        var staticRoutes:[any StaticRouteProtocol] = []
        var dynamicRoutes:[any DynamicRouteProtocol] = []
        for argument in function.arguments {
            if let label = argument.label?.text {
                switch label {
                case "endpoint":
                    endpoint = argument.expression.stringLiteral!.string
                case "staticMiddleware":
                    for argument in argument.expression.array!.elements {
                        if let function = argument.expression.functionCall {
                            staticMiddleware.append(StaticMiddleware.parse(context: context, function))
                        }
                    }
                case "dynamicMiddleware":
                    for argument in argument.expression.array!.elements {
                        if let function = argument.expression.functionCall {
                            dynamicMiddleware.append(DynamicMiddleware.parse(context: context, function))
                        }
                    }
                default:
                    break
                }
            } else if let function = argument.expression.functionCall {
                switch function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                case "StaticRoute":
                    if let route = StaticRoute.parse(context: context, version: version, function) {
                        staticRoutes.append(route)
                    }
                case "DynamicRoute":
                    if let route = DynamicRoute.parse(context: context, version: version, middleware: staticMiddleware, function) {
                        dynamicRoutes.append(route)
                    }
                default:
                    break
                }
            }
        }
        return Self(
            endpoint: endpoint,
            staticMiddleware: staticMiddleware,
            dynamicMiddleware: dynamicMiddleware,
            staticRoutes: staticRoutes,
            dynamicRoutes: dynamicRoutes
        )
    }
}
#endif