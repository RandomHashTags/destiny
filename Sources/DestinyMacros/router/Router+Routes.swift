
import Destiny
import SwiftSyntax
import SwiftSyntaxMacros

#if NonEmbedded
import DestinyDefaultsNonEmbedded
#endif

// MARK: Parse
extension Router {
    static func parseRoute(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        function: FunctionCallExprSyntax,
        storage: inout RouterStorage
    ) {
        //print("Router;expansion;route;function=\(function.debugDescription)")
        let decl:String?
        var targetMethod:HTTPRequestMethod? = nil
        if let member = function.calledExpression.memberAccess {
            decl = member.base?.as(DeclReferenceExprSyntax.self)?.baseName.text
            targetMethod = HTTPRequestMethod.parse(expr: member)
        } else {
            decl = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text
        }
        switch decl {

        #if NonEmbedded
        case "Route":
            #if StaticMiddleware
            var (staticRoute, dynamicRoute) = Route.parse(context: context, version: version, middleware: storage.staticMiddleware, function)
            #else
            var (staticRoute, dynamicRoute) = Route.parse(context: context, version: version, function)
            #endif
            if let method = targetMethod {
                staticRoute?.method = method
                dynamicRoute?.method = method
            }
            if let staticRoute {
                if staticRoute.isCaseSensitive {
                    storage.staticRouteStorage.caseSensitiveRoutes.append((staticRoute, function))
                } else {
                    storage.staticRouteStorage.caseInsensitiveRoutes.append((staticRoute, function))
                }
            } else if let dynamicRoute {
                if dynamicRoute.isCaseSensitive {
                    storage.dynamicRouteStorage.caseSensitiveRoutes.append((dynamicRoute, function))
                } else {
                    storage.dynamicRouteStorage.caseInsensitiveRoutes.append((dynamicRoute, function))
                }
            }
        #endif

        #if StaticRedirectionRoute
        case "StaticRedirectionRoute":
            let route = StaticRedirectionRoute.parse(context: context, version: version, function)
            storage.staticRedirects.append((route, function))
        #endif
        default:
            context.diagnose(DiagnosticMsg.unhandled(node: function.calledExpression))
        }
    }
}