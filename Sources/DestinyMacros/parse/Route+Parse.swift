
#if NonEmbedded

import DestinyBlueprint
import DestinyDefaults
import DestinyDefaultsNonEmbedded
import SwiftSyntax
import SwiftSyntaxMacros

#if MediaTypes
import MediaTypes
import MediaTypesSwiftSyntax
#endif

// MARK: Parse
extension Route {
    /// Parsing logic for this dynamic route. Computed at compile time.
    /// 
    /// - Parameters:
    ///   - context: Macro expansion context.
    ///   - version: `HTTPVersion` associated with the `HTTPRouterProtocol`.
    ///   - middleware: Static middleware the associated `HTTPRouterProtocol` uses.
    ///   - function: SwiftSyntax expression that represents this route at compile time.
    #if StaticMiddleware
    public static func parse(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        middleware: [any StaticMiddlewareProtocol],
        _ function: FunctionCallExprSyntax
    ) -> (static: StaticRoute?, dynamic: DynamicRoute?) {
        var details = parseDetails(context: context, version: version, function)
        var version = details.version
        var status = details.status
        var contentType = details.contentType
        var headers = HTTPHeaders()
        var cookies = [HTTPCookie]()
        let pathString = details.path.map({ $0.slug }).joined(separator: "/")
        for middleware in middleware {
            if middleware.handles(version: version, path: pathString, method: details.method, contentType: contentType, status: status) {
                middleware.apply(version: &version, contentType: &contentType, status: &status, headers: &headers, cookies: &cookies)
            }
        }
        details.version = version
        details.status = status
        details.contentType = contentType
        return parse(details: details, headers: &headers, cookies: cookies)
    }
    #else
    public static func parse(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        _ function: FunctionCallExprSyntax
    ) -> Self {
        let details = parseDetails(context: context, version: version, function)
        var headers = HTTPHeaders()
        return parse(details: details, headers: &headers, cookies: [])
    }
    #endif
    private static func parse(
        details: Details,
        headers: inout HTTPHeaders,
        cookies: [HTTPCookie]
    ) -> (StaticRoute?, DynamicRoute?) {
        if let contentType = details.contentType {
            headers["content-type"] = contentType
        }
        if details.path.firstIndex(where: { $0.isParameter }) == nil && details.handler == nil { // static route
            let route = StaticRoute(
                version: details.version,
                method: details.method,
                path: details.path.map({ $0.value }),
                isCaseSensitive: details.isCaseSensitive,
                status: details.status,
                contentType: details.contentType,
                charset: details.charset,
                body: details.body
            )
            return (route, nil)
        } else { // dynamic route
            var route = DynamicRoute(
                version: details.version,
                method: details.method,
                path: details.path,
                isCaseSensitive: details.isCaseSensitive,
                status: details.status,
                contentType: details.contentType,
                body: nil,
                handler: { _, _ in }
            )
            route.defaultResponse = DynamicResponse(
                message: HTTPResponseMessage(
                    version: details.version,
                    status: details.status,
                    headers: headers,
                    cookies: cookies,
                    body: details.body,
                    contentType: nil, // populating this would duplicate it in the response headers (if a contentType was provided)
                    charset: details.charset
                ),
                parameters: details.parameters
            )
            route.handlerDebugDescription = details.handler ?? "nil"
            return (nil, route)
        }
    }
}

// MARK: Parse details
extension Route {
    static func parseDetails(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        _ function: FunctionCallExprSyntax
    ) -> Details {
        var version = version
        var method:any HTTPRequestMethodProtocol = HTTPStandardRequestMethod.get
        var path = [PathComponent]()
        var isCaseSensitive = true
        var status = HTTPStandardResponseStatus.notImplemented.code
        var contentType:String? = nil
        var charset:Charset? = nil
        var body:(any ResponseBodyProtocol)? = nil
        var handler:String? = nil
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
                guard let parsed = HTTPResponseStatus.parseCode(context: context, expr: arg.expression) else {
                    break
                }
                status = parsed
            case "contentType":
                contentType = arg.expression.stringLiteralString(context: context) ?? contentType
            #if MediaTypes
            case "mediaType":
                guard let parsed = MediaType.parse(context: context, expr: arg.expression)?.template else {
                    context.diagnose(DiagnosticMsg.unhandled(node: arg))
                    break
                }
                contentType = parsed
            #endif
            case "charset":
                charset = Charset.init(expr: arg.expression)
            case "body":
                body = IntermediateResponseBody.parse(context: context, expr: arg.expression) ?? body
            case "handler":
                handler = "\(arg.expression)"
            default:
                context.diagnose(DiagnosticMsg.unhandled(node: arg))
            }
        }
        if !isCaseSensitive {
            path = path.map({ PathComponent(stringLiteral: $0.slug.lowercased()) })
        }
        return .init(
            version: version,
            method: method,
            path: path,
            isCaseSensitive: isCaseSensitive,
            status: status,
            contentType: contentType,
            charset: charset,
            body: body,
            handler: handler,
            parameters: parameters
        )
    }
}

// MARK: Details
extension Route {
    struct Details {
        var version:HTTPVersion
        var method:any HTTPRequestMethodProtocol = HTTPStandardRequestMethod.get
        var path = [PathComponent]()
        var isCaseSensitive = true
        var status = HTTPStandardResponseStatus.notImplemented.code
        var contentType:String? = nil
        var charset:Charset?
        var body:(any ResponseBodyProtocol)?
        var handler:String? = nil
        var parameters = [String]()
    }
}

#endif