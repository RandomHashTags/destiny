
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
        var version = details.head.version
        var status = details.head.status
        var contentType = details.contentType
        var headers = details.head.headers
        let pathString = details.path.map({ $0.slug }).joined(separator: "/")

        #if HTTPCookie
        var cookies = details.head.cookies
        #endif

        for middleware in middleware {
            if middleware.handles(version: version, path: pathString, method: details.method, contentType: contentType, status: status) {
                #if HTTPCookie
                middleware.apply(version: &version, contentType: &contentType, status: &status, headers: &headers, cookies: &cookies)
                #else
                middleware.apply(version: &version, contentType: &contentType, status: &status, headers: &headers)
                #endif
            }
        }
        details.head.headers = headers
        details.head.status = status
        details.head.version = version
        details.contentType = contentType

        #if HTTPCookie
        details.head.cookies = cookies
        return details.parse(headers: &headers, cookies: cookies)
        #else
        return details.parse(headers: &headers)
        #endif
    }
    #else
    public static func parse(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        _ function: FunctionCallExprSyntax
    ) -> Self {
        let details = parseDetails(context: context, version: version, function)
        #if HTTPCookie
        return parse(details: details, headers: &details.head.headers, cookies: details.head.cookies)
        #else
        return parse(details: details, headers: &details.head.headers)
        #endif
    }
    #endif
}

// MARK: Parse details
extension Route {
    static func parseDetails(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        _ function: FunctionCallExprSyntax
    ) -> Details {
        var head = HTTPResponseMessageHead.default
        head.version = version

        var method = HTTPRequestMethod(name: "GET")
        var path = [PathComponent]()
        var isCaseSensitive = true
        var contentType:String? = nil
        var charset:Charset? = nil
        var body:IntermediateResponseBody? = nil
        var handler:String? = nil
        var parameters = [String]()

        for arg in function.arguments {
            switch arg.label?.text {
            case "head":
                head = .parse(context: context, expr: arg.expression) ?? head
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
            head: head,
            method: method,
            path: path,
            isCaseSensitive: isCaseSensitive,
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
        var head:HTTPResponseMessageHead
        var method = HTTPRequestMethod(name: "GET")
        var path = [PathComponent]()
        var isCaseSensitive = true
        var contentType:String? = nil
        var charset:Charset?

        var body:IntermediateResponseBody?
        var handler:String? = nil
        var parameters = [String]()

        #if HTTPCookie
        fileprivate func parse(
            headers: inout HTTPHeaders,
            cookies: [HTTPCookie]
        ) -> (StaticRoute?, DynamicRoute?) {
            applyContentType(headers: &headers)
            let dynamicMessage = HTTPResponseMessage(
                version: head.version,
                status: head.status,
                headers: headers,
                cookies: cookies,
                body: body,
                contentType: nil, // populating this would duplicate it in the response headers (if a contentType was provided)
                charset: charset
            )
            return parse(headers: headers, dynamicMessage: dynamicMessage)
        }
        #else
        fileprivate func parse(
            headers: inout HTTPHeaders
        ) -> (StaticRoute?, DynamicRoute?) {
            applyContentType(headers: &headers)
            let dynamicMessage = HTTPResponseMessage(
                version: head.version,
                status: head.status,
                headers: headers,
                body: body,
                contentType: nil, // populating this would duplicate it in the response headers (if a contentType was provided)
                charset: charset
            )
            return parse(headers: headers, dynamicMessage: dynamicMessage)
        }
        #endif

        private func applyContentType(headers: inout HTTPHeaders) {
            guard let contentType else { return }
            headers["content-type"] = contentType
        }
        private func parse(
            headers: HTTPHeaders,
            dynamicMessage: HTTPResponseMessage
        ) -> (StaticRoute?, DynamicRoute?) {
            if path.firstIndex(where: { $0.isParameter }) == nil && handler == nil { // static route
                let route = StaticRoute(
                    version: head.version,
                    method: method,
                    path: path.map({ $0.value }),
                    isCaseSensitive: isCaseSensitive,
                    status: head.status,
                    contentType: contentType,
                    charset: charset,
                    body: body
                )
                return (route, nil)
            } else { // dynamic route
                var route = DynamicRoute(
                    version: head.version,
                    method: method,
                    path: path,
                    isCaseSensitive: isCaseSensitive,
                    status: head.status,
                    contentType: contentType,
                    body: nil,
                    handler: { _, _ in }
                )
                route.defaultResponse = DynamicResponse(
                    message: dynamicMessage,
                    parameters: parameters
                )
                route.handlerDebugDescription = handler ?? "nil"
                return (nil, route)
            }
        }
    }
}

#endif