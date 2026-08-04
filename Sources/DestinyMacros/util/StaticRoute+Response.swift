
import Destiny
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

#if Compression
import SwiftCompression
#endif

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
        routerStorage: RouterStorage,
        middleware: [StaticMiddleware]
    ) -> HTTPResponseMessage {
        let result = response(routerStorage: routerStorage, middleware: middleware)
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
            routerStorage: RouterStorage,
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
                routerStorage: routerStorage,
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
        routerStorage: RouterStorage,

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

        #if RouterSettings && Compression
        if body != nil, let contentType, routerStorage.settings.compression.isEnabled {
            for (algorithm, algorithmSettings) in routerStorage.settings.compression.supportedCompressionAlgorithms {
                if let prefixBlacklist = algorithmSettings.contentTypePrefixBlacklist, contentType.hasPrefix(prefixBlacklist) {
                    continue
                }
                if algorithmSettings.contentTypeBlacklist.contains(contentType) {
                    continue
                }
                if let prefixWhitelist = algorithmSettings.contentTypePrefixWhitelist, !contentType.hasPrefix(prefixWhitelist) {
                    continue
                }
                guard algorithmSettings.contentTypeWhitelist.isEmpty || algorithmSettings.contentTypeWhitelist.contains(contentType) else {
                    continue
                }
                if let contentLengthThreshold = algorithmSettings.contentLengthThreshold, body!.count < contentLengthThreshold {
                    continue
                }
                if let compressed = algorithm.compress(span: body!.value.utf8Span.span) {
                    if routerStorage.settings.compression.compressOnlyIfResultIsSmaller, compressed.count >= body!.count {
                        continue
                    }
                    headers["content-encoding"] = algorithm.acceptEncodingName
                    headers["vary"] = "Accept-Encoding"
                    body!.rawValue = compressed
                    if case let .string(isNonCopyable, isStatic, withDateHeader, _) = body!.type {
                        body!.type = .string(isNonCopyable: isNonCopyable, isStatic: isStatic, withDateHeader: withDateHeader, withCompressedBody: true)
                    }
                    break
                }
            }
        }
        #endif

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