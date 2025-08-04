
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension RouteGroup {
    /// Parsing logic for this router group.
    /// 
    /// - Parameters:
    ///   - context: The macro expansion context.
    ///   - version: The `HTTPVersion` of the router this router group belongs to.
    ///   - staticMiddleware: The static middleware of the router this router group belongs to.
    ///   - dynamicMiddleware: The dynamic middleware of the router this router group belongs to.
    ///   - function: SwiftSyntax expression that represents this router group at compile time.
    public static func parse(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        staticMiddleware: [any StaticMiddlewareProtocol],
        dynamicMiddleware: [FunctionCallExprSyntax],
        _ function: FunctionCallExprSyntax
    ) -> DeclSyntax {
        var storage = Router.Storage()
        var endpoint = ""
        var conditionalResponders = [DestinyRoutePathType:any ConditionalRouteResponderProtocol]()
        var staticMiddleware = staticMiddleware
        for f in dynamicMiddleware {
            Router.parseDynamicMiddleware(context: context, function: f, storage: &storage)
        }
        
        for arg in function.arguments {
            if let label = arg.label?.text {
                switch label {
                case "endpoint":
                    guard let string = arg.expression.stringLiteralString(context: context) else { break }
                    endpoint = string
                case "staticMiddleware":
                    guard let array = arg.expression.arrayElements(context: context) else { break }
                    for arg in array {
                        if let function = arg.expression.functionCall {
                            staticMiddleware.append(StaticMiddleware.parse(context: context, function))
                        }
                    }
                case "dynamicMiddleware":
                    guard let array = arg.expression.arrayElements(context: context) else { break }
                    for arg in array {
                        if let function = arg.expression.functionCall {
                            Router.parseDynamicMiddleware(context: context, function: function, storage: &storage)
                        }
                    }
                default:
                    break
                }
            } else if let function = arg.expression.functionCall {
                Router.parseRoute(context: context, version: version, function: function, storage: &storage)
            }
        }

        let prefixEndpoints = endpoint.split(separator: "/").map({ String($0) })
        var staticResponses = StaticResponderStorage()
        for (var route, routeFunction) in storage.staticRoutes {
            route.insertPath(contentsOf: prefixEndpoints, at: 0)
            do throws(HTTPMessageError) {
                if let responder = try route.responder(middleware: staticMiddleware) {
                    staticResponses.register(path: DestinyRoutePathType(route.startLine), responder)
                } else {
                    context.diagnose(DiagnosticMsg.unhandled(node: routeFunction))
                }
            } catch {
                context.diagnose(DiagnosticMsg.unhandled(node: routeFunction, notes: "error=\(error)"))
            }
        }

        let pathComponents = prefixEndpoints.map({ PathComponent.literal($0) })
        var parameterless = [DestinyRoutePathType:any DynamicRouteResponderProtocol]()
        var parameterized = [[any DynamicRouteResponderProtocol]]()
        for (var route, routeFunction) in storage.dynamicRoutes {
            route.insertPath(contentsOf: pathComponents, at: 0)
            let responder = route.responder()
            if route.pathContainsParameters {
                let pathCount = route.pathCount
                if parameterized.count <= pathCount {
                    for _ in 0...(pathCount - parameterized.count) {
                        parameterized.append([])
                    }
                }
                parameterized[pathCount].append(responder)
            } else {
                parameterless[DestinyRoutePathType(route.startLine())] = responder
            }
        }
        let dynamicResponses = DynamicResponderStorage(
            parameterless: parameterless,
            parameterized: parameterized,
            catchall: []
        ) // TODO: fix catchall

        let staticMiddlewareString = staticMiddleware.map({ "\($0)" }).joined(separator: ",\n")
        let dynamicMiddlewareString = storage.dynamicMiddleware.map({ "\($0)" }).joined(separator: ",\n")

        let immutableStaticMiddlewareString:String
        if staticMiddleware.isEmpty {
            immutableStaticMiddlewareString = "Optional<CompiledStaticMiddlewareStorage<StaticMiddleware>>.none"
        } else {
            immutableStaticMiddlewareString = "CompiledStaticMiddlewareStorage((\n\(staticMiddlewareString)\n))"
        }

        let immutableDynamicMiddleware:String
        if storage.dynamicMiddleware.isEmpty {
            immutableDynamicMiddleware = "Optional<CompiledDynamicMiddlewareStorage<DynamicMiddleware>>.none"
        } else {
            immutableDynamicMiddleware = "CompiledDynamicMiddlewareStorage((\n\(dynamicMiddlewareString)\n))"
        }

        let compiled = """
        CompiledRouteGroup(
            prefixEndpoints: \(prefixEndpoints),
            immutableStaticMiddleware: \(immutableStaticMiddlewareString),
            immutableDynamicMiddleware: \(immutableDynamicMiddleware),
            immutableStaticResponders: Optional<CompiledStaticResponderStorage<CompiledStaticResponderStorageRoute<StringWithDateHeader>>>.none,
            mutableStaticResponders: \(staticResponses),
            immutableDynamicResponders: Optional<CompiledDynamicResponderStorage<CompiledDynamicResponderStorageRoute<DynamicRouteResponder>>>.none,
            mutableDynamicResponders: \(dynamicResponses)
        )
        """
        return DeclSyntax(stringLiteral: compiled)
    }
}