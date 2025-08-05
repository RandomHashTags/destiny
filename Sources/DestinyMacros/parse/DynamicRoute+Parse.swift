
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: Responder DebugDescription
extension DynamicRoute {
    /// String representation of an initialized route responder conforming to `DynamicRouteResponderProtocol`.
    public var responderDebugDescription: String {
        """
        DynamicRouteResponder(
            path: \(path),
            defaultResponse: \(defaultResponse),
            logic: \(handlerDebugDescription)
        )
        """
    }
}

// MARK: Parse
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
    ) -> Self {
        var version = version
        var method:any HTTPRequestMethodProtocol = HTTPStandardRequestMethod.get
        var path = [PathComponent]()
        var isCaseSensitive = true
        var status = HTTPStandardResponseStatus.notImplemented.code
        var contentType:HTTPMediaType? = nil
        var handler = "nil"
        var parameters = [String]()
        for arg in function.arguments {
            switch arg.label?.text {
            case "version":
                guard let parsed = HTTPVersion.parse(context: context, expr: arg.expression) else { break }
                version = parsed
            case "method":
                guard let parsed = HTTPRequestMethod.parse(expr: arg.expression) else {
                    context.diagnose(DiagnosticMsg.unhandled(node: arg.expression))
                    break
                }
                method = parsed
            case "path":
                path = PathComponent.parseArray(context: context, arg.expression)
                for _ in path.filter({ $0.isParameter }) {
                    parameters.append("")
                }
            case "isCaseSensitive", "caseSensitive":
                isCaseSensitive = arg.expression.booleanIsTrue
            case "status":
                guard let parsed = HTTPResponseStatus.parseCode(expr: arg.expression) else {
                    context.diagnose(DiagnosticMsg.unhandled(node: arg.expression))
                    break
                }
                status = parsed
            case "contentType":
                guard let parsed = HTTPMediaType.parse(context: context, expr: arg.expression) else {
                    context.diagnose(DiagnosticMsg.unhandled(node: arg.expression))
                    break
                }
                contentType = parsed
            case "handler":
                handler = "\(arg.expression)"
            default:
                context.diagnose(DiagnosticMsg.unhandled(node: arg))
            }
        }
        var headers = HTTPHeaders()
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
            headers[HTTPStandardResponseHeader.contentType.rawName] = "\(contentType)"
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