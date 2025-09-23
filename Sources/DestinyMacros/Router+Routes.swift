
import DestinyBlueprint
import DestinyDefaults
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
        case "DynamicRoute":
            #if StaticMiddleware
            var route = DynamicRoute.parse(context: context, version: version, middleware: storage.staticMiddleware, function)
            #else
            var route = DynamicRoute.parse(context: context, version: version, function)
            #endif
            if let method = targetMethod {
                route.method = method
            }
            if route.isCaseSensitive {
                storage.dynamicRouteStorage.caseSensitiveRoutes.append((route, function))
            } else {
                storage.dynamicRouteStorage.caseInsensitiveRoutes.append((route, function))
            }
        case "StaticRoute":
            var route = StaticRoute.parse(context: context, version: version, function)
            if let method = targetMethod {
                route.method = method
            }
            if route.isCaseSensitive {
                storage.staticRouteStorage.caseSensitiveRoutes.append((route, function))
            } else {
                storage.staticRouteStorage.caseInsensitiveRoutes.append((route, function))
            }
        #endif

        case "StaticRedirectionRoute":
            let route = StaticRedirectionRoute.parse(context: context, version: version, function)
            storage.staticRedirects.append((route, function))
        default:
            context.diagnose(DiagnosticMsg.unhandled(node: function.calledExpression))
        }
    }
}