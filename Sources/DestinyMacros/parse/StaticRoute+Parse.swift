
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
        var path = [String]()
        var isCaseSensitive = true
        var status = HTTPStandardResponseStatus.notImplemented.code
        var contentType = HTTPMediaType(HTTPMediaTypeText.plain)
        var charset:Charset? = nil
        var body:(any ResponseBodyProtocol)? = nil
        for arg in function.arguments {
            switch arg.label?.text {
            case "version":
                version = HTTPVersion.parse(context: context, expr: arg.expression) ?? version
            case "method":
                method = HTTPRequestMethod.parse(expr: arg.expression) ?? method
            case "path":
                path = PathComponent.parseArray(context: context, expr: arg.expression)
            case "isCaseSensitive", "caseSensitive":
                isCaseSensitive = arg.expression.booleanIsTrue
            case "status":
                status = HTTPResponseStatus.parseCode(expr: arg.expression) ?? status
            case "contentType":
                contentType = HTTPMediaType.parse(context: context, expr: arg.expression) ?? contentType
            case "charset":
                charset = Charset(expr: arg.expression)
            case "body":
                body = ResponseBody.parse(context: context, expr: arg.expression) ?? body
            default:
                context.diagnose(DiagnosticMsg.unhandled(node: arg))
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
    /// Builds the HTTP Message for this route.
    /// 
    /// - Parameters:
    ///   - context: Macro expansion context where it was called.
    ///   - function: `FunctionCallExprSyntax` that represents this route.
    ///   - middleware: Static middleware this route will handle.
    public func response(
        context: MacroExpansionContext,
        function: FunctionCallExprSyntax,
        middleware: [some StaticMiddlewareProtocol]
    ) -> some HTTPMessageProtocol {
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
    ///   - context: Macro expansion context where it was called.
    ///   - function: `FunctionCallExprSyntax` that represents this route.
    ///   - middleware: Static middleware that this route will handle.
    public func responder(
        context: MacroExpansionContext,
        function: FunctionCallExprSyntax,
        middleware: [some StaticMiddlewareProtocol]
    ) throws(HTTPMessageError) -> (any StaticRouteResponderProtocol)? {
        return try response(context: context, function: function, middleware: middleware).string(escapeLineBreak: true)
    }
}