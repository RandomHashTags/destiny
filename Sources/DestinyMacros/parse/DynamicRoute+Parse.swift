
import DestinyBlueprint
import DestinyDefaults
import OrderedCollections
import SwiftSyntax
import SwiftSyntaxMacros

extension DynamicRoute {
    /// Parsing logic for this dynamic route. Computed at compile time.
    /// 
    /// - Parameters:
    ///   - context: The macro expansion context.
    ///   - version: The `HTTPVersion` associated with the `HTTPRouterProtocol`.
    ///   - middleware: The static middleware the associated `HTTPRouterProtocol` uses.
    ///   - function: SwiftSyntax expression that represents this route at compile time.
    /// - Warning: You should apply any statuses and headers using the middleware.
    public static func parse(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        middleware: [any StaticMiddlewareProtocol],
        _ function: FunctionCallExprSyntax
    ) -> Self? {
        var version = version
        var method:any HTTPRequestMethodProtocol = HTTPRequestMethod.get
        var path:[PathComponent] = []
        var isCaseSensitive = true
        var status = HTTPResponseStatus.notImplemented.code
        var contentType:HTTPMediaType? = nil
        var handler = "nil"
        var parameters = [String]()
        for argument in function.arguments {
            switch argument.label?.text {
            case "version":
                if let parsed = HTTPVersion.parse(argument.expression) {
                    version = parsed
                }
            case "method":
                method = HTTPRequestMethod.parse(expr: argument.expression) ?? method
            case "path":
                path = PathComponent.parseArray(context: context, argument.expression)
                for _ in path.filter({ $0.isParameter }) {
                    parameters.append("")
                }
            case "isCaseSensitive", "caseSensitive":
                isCaseSensitive = argument.expression.booleanIsTrue
            case "status":
                status = HTTPResponseStatus.parseCode(expr: argument.expression) ?? status
            case "contentType":
                contentType = HTTPMediaType.parse(context: context, expr: argument.expression) ?? contentType
            case "handler":
                handler = "\(argument.expression)"
            default:
                break
            }
        }
        var headers = OrderedDictionary<String, String>()
        var cookies = [any HTTPCookieProtocol]()
        if !isCaseSensitive {
            path = path.map({ PathComponent(stringLiteral: $0.slug.lowercased()) })
        }
        let pathString = path.map({ $0.slug }).joined(separator: "/")
        for middleware in middleware {
            if middleware.handles(version: version, path: pathString, method: method, contentType: contentType, status: status) {
                middleware.apply(version: &version, contentType: &contentType, status: &status, headers: &headers, cookies: &cookies)
            }
        }
        if let contentType {
            headers[HTTPResponseHeader.contentType.rawNameString] = "\(contentType)"
        }
        var route = DynamicRoute(
            version: version,
            method: method,
            path: path,
            isCaseSensitive: isCaseSensitive,
            status: status,
            contentType: contentType,
            handler: { _, _ in }
        )
        route.defaultResponse = DynamicResponse(
            message: HTTPResponseMessage(version: version, status: status, headers: headers, cookies: cookies, body: nil, contentType: nil, charset: nil),
            parameters: parameters
        )
        route.handlerDebugDescription = handler
        return route
    }
}