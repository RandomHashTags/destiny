
import Destiny
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import Zlib

extension StaticRoute {
    /// Builds the HTTP Message for this route.
    /// 
    /// - Parameters:
    ///   - context: Macro expansion context where it was called.
    ///   - function: `FunctionCallExprSyntax` that represents this route.
    ///   - middleware: Static middleware this route will handle.
    #if StaticMiddleware
    public mutating func response(
        context: some MacroExpansionContext,
        function: FunctionCallExprSyntax,
        middleware: [StaticMiddleware]
    ) -> HTTPResponseMessage {
        let result = response(middleware: middleware)
        if result.statusCode() == 501 { // not implemented
            Diagnostic.routeResponseStatusNotImplemented(context: context, node: function.calledExpression)
        }
        return result
    }
    #else
    public mutating func response(
        context: some MacroExpansionContext,
        function: FunctionCallExprSyntax
    ) -> HTTPResponseMessage {
        let result = response()
        if result.statusCode() == 501 { // not implemented
            Diagnostic.routeResponseStatusNotImplemented(context: context, node: function.calledExpression)
        }
        return result
    }
    #endif
}

extension StaticRoute {
    #if StaticMiddleware
        public mutating func response(
            middleware: [StaticMiddleware]
        ) -> HTTPResponseMessage {
            var version = version
            let path = path.joined(separator: "/")
            var status = status
            var contentType = contentType
            var headers = HTTPHeaders()
            if body?.hasDateHeader ?? false {
                headers["date"] = HTTPDateFormat.placeholder
            }

            #if HTTPCookie
            var cookies = [HTTPCookie]()
            #endif

            middleware.forEach { middleware in
                if middleware.handles(version: version, path: path, method: method, contentType: contentType, status: status) {
                    #if HTTPCookie
                    middleware.apply(version: &version, contentType: &contentType, status: &status, headers: &headers, cookies: &cookies)
                    #else
                    middleware.apply(version: &version, contentType: &contentType, status: &status, headers: &headers)
                    #endif
                }
            }
            headers["content-type"] = nil
            headers["content-length"] = nil

            #if HTTPCookie
            return Self.response(
                version: version,
                status: status,
                headers: &headers,
                cookies: cookies,
                body: &body,
                contentType: contentType,
                charset: charset
            )
            #else
            return Self.response(
                version: version,
                status: status,
                headers: &headers,
                body: body,
                contentType: contentType,
                charset: charset
            )
            #endif
        }
    #else
        public mutating func response() -> HTTPResponseMessage {
            var headers = HTTPHeaders()
            if body?.hasDateHeader ?? false {
                headers["date"] = HTTPDateFormat.placeholder
            }
            headers["content-type"] = nil
            headers["content-length"] = nil
            #if HTTPCooke
            return Self.response(version: version, status: status, headers: &headers, cookies: [], body: body, contentType: contentType, charset: charset)
            #else
            return Self.response(version: version, status: status, headers: &headers, body: body, contentType: contentType, charset: charset)
            #endif
        }
    #endif
}

// MARK: Static
extension StaticRoute {
    #if HTTPCookie
    @inline(__always)
    package static func response(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: inout HTTPHeaders,
        cookies: [HTTPCookie],
        body: inout IntermediateResponseBody?,
        contentType: String?,
        charset: Charset?
    ) -> HTTPResponseMessage {
        headers["content-type"] = nil
        headers["content-length"] = nil

        if body != nil, contentType == "text/html" {
            if let compressed = Gzip().compress(span: body!.value.utf8Span.span) {
                headers["content-encoding"] = "gzip"
                headers["vary"] = "Accept-Encoding"
                body!.rawValue = compressed
            }
        }
        return HTTPResponseMessage(
            head: .init(headers: headers, cookies: cookies, status: status, version: version),
            body: body,
            contentType: contentType,
            charset: charset
        )
    }
    #else
    @inline(__always)
    package static func response(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: inout HTTPHeaders,
        body: IntermediateResponseBody?,
        contentType: String?,
        charset: Charset?
    ) -> HTTPResponseMessage {
        headers["content-type"] = nil
        headers["content-length"] = nil
        return HTTPResponseMessage(
            head: .init(headers: headers, status: status, version: version),
            body: body,
            contentType: contentType,
            charset: charset
        )
    }
    #endif
}