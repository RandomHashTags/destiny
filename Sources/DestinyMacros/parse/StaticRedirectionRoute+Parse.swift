
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension StaticRedirectionRoute {
    /// Parsing logic for this route.
    /// 
    /// - Parameters:
    ///   - context: Macro expansion context where this route is being parsed from.
    ///   - version: `HTTPVersion` of the `HTTPRouterProtocol` this middleware is assigned to.
    ///   - function: `FunctionCallExprSyntax` that represents this route.
    public static func parse(
        context: some MacroExpansionContext,
        version: HTTPVersion, 
        _ function: FunctionCallExprSyntax
    ) -> Self {
        var version = version
        var method:any HTTPRequestMethodProtocol = HTTPStandardRequestMethod.get
        var from = [String]()
        var isCaseSensitive = true
        var to = [String]()
        var status = HTTPStandardResponseStatus.movedPermanently.code
        for arg in function.arguments {
            switch arg.label?.text {
            case "version":
                version = HTTPVersion.parse(context: context, expr: arg.expression) ?? version
            case "method":
                method = HTTPRequestMethod.parse(expr: arg.expression) ?? method
            case "status":
                status = HTTPResponseStatus.parseCode(context: context, expr: arg.expression) ?? status
            case "from":
                from = PathComponent.parseArray(context: context, expr: arg.expression)
            case "isCaseSensitive", "caseSensitive":
                isCaseSensitive = arg.expression.booleanIsTrue
            case "to":
                to = PathComponent.parseArray(context: context, expr: arg.expression)
            default:
                context.diagnose(DiagnosticMsg.unhandled(node: arg))
            }
        }
        var route = Self(version: version, method: method, status: status, from: [], isCaseSensitive: isCaseSensitive, to: [])
        route.from = from
        route.to = to
        return route
    }
}