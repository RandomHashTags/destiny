
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: Parse
extension Router {
    static func parseRoute(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        function: FunctionCallExprSyntax,
        storage: inout Storage
    ) {
        //print("Router;expansion;route;function=\(function.debugDescription)")
        let decl:String?
        var targetMethod:(any HTTPRequestMethodProtocol)? = nil
        if let member = function.calledExpression.memberAccess {
            decl = member.base?.as(DeclReferenceExprSyntax.self)?.baseName.text
            targetMethod = HTTPRequestMethod.parse(expr: member)
        } else {
            decl = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text
        }
        switch decl {
        case "DynamicRoute":
            var route = DynamicRoute.parse(context: context, version: version, middleware: storage.staticMiddleware, function)
            if let method = targetMethod {
                route.method = method
            }
            storage.dynamicRoutes.append((route, function))
        case "StaticRoute":
            var route = StaticRoute.parse(context: context, version: version, function)
            if let method = targetMethod {
                route.method = method
            }
            storage.staticRoutes.append((route, function))
        case "StaticRedirectionRoute":
            let route = StaticRedirectionRoute.parse(context: context, version: version, function)
            storage.staticRedirects.append((route, function))
        default:
            context.diagnose(DiagnosticMsg.unhandled(node: function.calledExpression))
        }
    }
}