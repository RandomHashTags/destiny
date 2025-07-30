
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension StaticRedirectionRoute {
    /// Parsing logic for this route. Computed at compile time.
    /// 
    /// - Parameters:
    ///   - context: The macro expansion context where this route is being parsed from.
    ///   - version: The `HTTPVersion` of the `HTTPRouterProtocol` this middleware is assigned to.
    ///   - function: SwiftSyntax expression that represents this route.
    public static func parse(
        context: some MacroExpansionContext,
        version: HTTPVersion, 
        _ function: FunctionCallExprSyntax
    ) -> Self? {
        var version = version
        var method:any HTTPRequestMethodProtocol = HTTPStandardRequestMethod.get
        var from = [String]()
        var isCaseSensitive = true
        var to = [String]()
        var status = HTTPResponseStatus.movedPermanently.code
        for argument in function.arguments {
            switch argument.label?.text {
            case "version": version = HTTPVersion.parse(argument.expression) ?? version
            case "method": method = HTTPRequestMethod.parse(expr: argument.expression) ?? method
            case "status": status = HTTPResponseStatus.parseCode(expr: argument.expression) ?? status
            case "from": from = PathComponent.parseArray(context: context, argument.expression)
            case "isCaseSensitive", "caseSensitive": isCaseSensitive = argument.expression.booleanIsTrue
            case "to": to = PathComponent.parseArray(context: context, argument.expression)
            default: break
            }
        }
        var route = Self(version: version, method: method, status: status, from: [], isCaseSensitive: isCaseSensitive, to: [])
        route.from = from
        route.to = to
        return route
    }
}