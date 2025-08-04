
import DestinyBlueprint
import DestinyDefaults
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: Parse
extension StaticRoute {
    /// Parsing logic for this route.
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
        var path = [String]()
        var isCaseSensitive = true
        var status = HTTPStandardResponseStatus.notImplemented.code
        var contentType = HTTPMediaType(HTTPMediaTypeText.plain)
        var charset:Charset? = nil
        var body:(any ResponseBodyProtocol)? = nil
        for argument in function.arguments {
            switch argument.label?.text {
            case "version":
                version = HTTPVersion.parse(argument.expression) ?? version
            case "method":
                method = HTTPRequestMethod.parse(expr: argument.expression) ?? method
            case "path":
                path = PathComponent.parseArray(context: context, argument.expression)
            case "isCaseSensitive", "caseSensitive":
                isCaseSensitive = argument.expression.booleanIsTrue
            case "status":
                status = HTTPResponseStatus.parseCode(expr: argument.expression) ?? status
            case "contentType":
                contentType = HTTPMediaType.parse(context: context, expr: argument.expression) ?? contentType
            case "charset":
                charset = Charset(expr: argument.expression)
            case "body":
                body = ResponseBody.parse(context: context, expr: argument.expression) ?? body
            default:
                break
            }
        }
        return StaticRoute(
            version: version,
            method: method,
            path: isCaseSensitive ? path : path.map({ $0.lowercased() }),
            isCaseSensitive: isCaseSensitive,
            status: status,
            contentType: contentType,
            charset: charset,
            body: body
        )
    }
}

// MARK: Response
extension StaticRoute {
    /// The HTTP Message of this route.
    /// 
    /// - Parameters:
    ///   - context: The macro expansion context where it was called.
    ///   - function: SwiftSyntax expression that represents this route.
    ///   - middleware: Static middleware that this route will apply.
    /// - Returns: An `HTTPResponseMessage`.
    /// - Warning: You should apply any statuses and headers using the middleware.
    public func response(
        context: MacroExpansionContext,
        function: FunctionCallExprSyntax,
        middleware: [some StaticMiddlewareProtocol]
    ) -> any HTTPMessageProtocol {
        var version = version
        let path = path.joined(separator: "/")
        var status = status
        var contentType = contentType
        var headers = HTTPHeaders()
        if body?.hasDateHeader ?? false {
            headers["Date"] = HTTPDateFormat.placeholder
        }
        var cookies = [any HTTPCookieProtocol]()
        for middleware in middleware {
            if middleware.handles(version: version, path: path, method: method, contentType: contentType, status: status) {
                middleware.apply(version: &version, contentType: &contentType, status: &status, headers: &headers, cookies: &cookies)
            }
        }
        if status == HTTPStandardResponseStatus.notImplemented.code {
            Diagnostic.routeResponseStatusNotImplemented(context: context, node: function.calledExpression)
        }
        headers[HTTPStandardResponseHeader.contentType.rawName] = nil
        headers[HTTPStandardResponseHeader.contentLength.rawName] = nil
        return HTTPResponseMessage(version: version, status: status, headers: headers, cookies: cookies, body: body, contentType: contentType, charset: charset)
    }
}

// MARK: Responder
extension StaticRoute {
    /// The `StaticRouteResponderProtocol` responder for this route.
    /// 
    /// - Parameters:
    ///   - context: The macro expansion context where it was called.
    ///   - function: SwiftSyntax expression that represents this route.
    ///   - middleware: Static middleware that this route will apply.
    /// - Throws: any error.
    public func responder(
        context: MacroExpansionContext,
        function: FunctionCallExprSyntax,
        middleware: [some StaticMiddlewareProtocol]
    ) throws(HTTPMessageError) -> (any StaticRouteResponderProtocol)? {
        return try response(context: context, function: function, middleware: middleware).string(escapeLineBreak: true)
    }
}