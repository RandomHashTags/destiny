
#if NonEmbedded

import DestinyBlueprint
import DestinyDefaults
import DestinyDefaultsNonEmbedded
import SwiftSyntax
import SwiftSyntaxMacros

#if MediaTypes
import MediaTypes
#endif

// MARK: Responder DebugDescription
extension DynamicRoute {
    /// String representation of an initialized route responder conforming to `DynamicRouteResponderProtocol`.
    public func responderDebugDescription(useGenerics: Bool) -> String {
        var response:String = "\(defaultResponse)"
        #if GenericDynamicResponse
        if useGenerics {
            // TODO: convert body to `IntermediateBody`
            if let b = defaultResponse.message.body as? StaticString {
                response = genericResponse(b)
            } else if let b = defaultResponse.message.body as? String {
                response = genericResponse(b)
            } else {
                response = genericResponse(Optional<StaticString>.none)
            }
        }
        #endif
        return """
        DynamicRouteResponder(
            path: \(path),
            defaultResponse: \(response),
            logic: \(handlerDebugDescription)
        )
        """
    }

    #if GenericDynamicResponse
    private func genericResponse<Body: ResponseBodyProtocol>(_ body: Body?) -> String {
        let response = GenericDynamicResponse(
            message: GenericHTTPResponseMessage<Body, HTTPCookie>(
                head: defaultResponse.message.head,
                body: body,
                contentType: defaultResponse.message.contentType,
                charset: defaultResponse.message.charset
            ),
            parameters: defaultResponse.parameters
        )
        return "\(response)"
    }
    #endif
}

// MARK: Parse
extension DynamicRoute {
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
    ) -> Self {
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
    ) -> Self {
        if let contentType = details.contentType {
            headers[HTTPStandardResponseHeader.contentType.rawName] = "\(contentType)"
        }
        var route = DynamicRoute(
            version: details.version,
            method: details.method,
            path: details.path,
            isCaseSensitive: details.isCaseSensitive,
            status: details.status,
            contentType: details.contentType,
            handler: { _, _ in }
        )
        route.defaultResponse = DynamicResponse(
            message: HTTPResponseMessage(
                version: details.version,
                status: details.status,
                headers: headers,
                cookies: cookies,
                body: nil,
                contentType: nil,
                charset: nil
            ),
            parameters: details.parameters
        )
        route.handlerDebugDescription = details.handler
        return route
    }
}

// MARK: Parse details
extension DynamicRoute {
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
                guard let parsed = HTTPResponseStatus.parseCode(context: context, expr: arg.expression) else {
                    break
                }
                status = parsed
            case "contentType":
                contentType = arg.expression.stringLiteralString(context: context) ?? contentType
            case "mediaType":
                #if MediaTypes
                guard let parsed = MediaType.parse(context: context, expr: arg.expression)?.template else {
                    context.diagnose(DiagnosticMsg.unhandled(node: arg.expression))
                    break
                }
                contentType = parsed
                #else
                context.diagnose(DiagnosticMsg.unhandled(node: arg))
                #endif
            case "handler":
                handler = "\(arg.expression)"
            default:
                context.diagnose(DiagnosticMsg.unhandled(node: arg))
            }
        }
        if !isCaseSensitive {
            path = path.map({ PathComponent(stringLiteral: $0.slug.lowercased()) })
        }
        return .init(version: version, method: method, path: path, isCaseSensitive: isCaseSensitive, status: status, contentType: contentType, handler: handler, parameters: parameters)
    }
}

// MARK: Details
extension DynamicRoute {
    struct Details {
        var version:HTTPVersion
        var method:any HTTPRequestMethodProtocol = HTTPStandardRequestMethod.get
        var path = [PathComponent]()
        var isCaseSensitive = true
        var status = HTTPStandardResponseStatus.notImplemented.code
        var contentType:String? = nil
        var handler = "nil"
        var parameters = [String]()
    }
}

#endif