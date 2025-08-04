
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
    ) -> Self {
        var endpoint = ""
        var conditionalResponders = [DestinyRoutePathType:any ConditionalRouteResponderProtocol]()
        var staticMiddleware = staticMiddleware
        var dynamicMiddleware = dynamicMiddleware.compactMap({ DynamicMiddleware.parse(context: context, $0) })
        var staticRoutes = [any StaticRouteProtocol]()
        var dynamicRoutes = [any DynamicRouteProtocol]()
        for arg in function.arguments {
            if let label = arg.label?.text {
                switch label {
                case "endpoint":
                    endpoint = arg.expression.stringLiteral!.string
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
                            dynamicMiddleware.append(DynamicMiddleware.parse(context: context, function))
                        }
                    }
                default:
                    break
                }
            } else if let function = arg.expression.functionCall {
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
        fatalError("not yet supported") // TODO: fix
        /*
        return Self(
            endpoint: endpoint,
            staticMiddleware: staticMiddleware,
            dynamicMiddleware: dynamicMiddleware,
            staticRoutes: staticRoutes,
            dynamicRoutes: dynamicRoutes
        )*/
    }
}