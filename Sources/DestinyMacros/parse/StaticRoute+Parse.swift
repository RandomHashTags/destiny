
#if NonEmbedded

import DestinyBlueprint
import DestinyDefaults
import DestinyDefaultsNonEmbedded
import HTTPMediaTypes
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
    #if StaticMiddleware
    public func response(
        context: MacroExpansionContext,
        function: FunctionCallExprSyntax,
        middleware: [some StaticMiddlewareProtocol]
    ) -> some HTTPMessageProtocol {
        let result = response(middleware: middleware)
        if result.statusCode() == HTTPStandardResponseStatus.notImplemented.code {
            Diagnostic.routeResponseStatusNotImplemented(context: context, node: function.calledExpression)
        }
        return result
    }
    #else
    public func response(
        context: MacroExpansionContext,
        function: FunctionCallExprSyntax
    ) -> some HTTPMessageProtocol {
        let result = response()
        if result.statusCode() == HTTPStandardResponseStatus.notImplemented.code {
            Diagnostic.routeResponseStatusNotImplemented(context: context, node: function.calledExpression)
        }
        return result
    }
    #endif
}

// MARK: Responder
extension StaticRoute {
    /// The `StaticRouteResponderProtocol` responder for this route.
    /// 
    /// - Parameters:
    ///   - context: Macro expansion context where it was called.
    ///   - function: `FunctionCallExprSyntax` that represents this route.
    ///   - middleware: Static middleware that this route will handle.
    #if StaticMiddleware
    public func responder(
        context: MacroExpansionContext,
        function: FunctionCallExprSyntax,
        middleware: [some StaticMiddlewareProtocol]
    ) throws(HTTPMessageError) -> (any StaticRouteResponderProtocol)? {
        return try response(context: context, function: function, middleware: middleware).string(escapeLineBreak: true)
    }
    #else
    public func responder(
        context: MacroExpansionContext,
        function: FunctionCallExprSyntax
    ) throws(HTTPMessageError) -> (any StaticRouteResponderProtocol)? {
        return try response(context: context, function: function).string(escapeLineBreak: true)
    }
    #endif
}

#endif