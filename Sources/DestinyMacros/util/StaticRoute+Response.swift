
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
    public mutating func responses(
        context: some MacroExpansionContext,
        function: FunctionCallExprSyntax,
        routerStorage: RouterStorage,
        middleware: [StaticMiddleware]
    ) -> [IntermediateHTTPMessage] {
        let results = responses(routerStorage: routerStorage, middleware: middleware)
        for msg in results {
            if msg.head.status == 501 { // not implemented
                Diagnostic.routeResponseStatusNotImplemented(context: context, node: function.calledExpression)
            }
        }
        return results
    }
    #else
    public mutating func responses(
        context: some MacroExpansionContext,
        function: FunctionCallExprSyntax
    ) -> HTTPResponseMessage {
        let results = responses()
        for msg in results {
            if msg.head.status == 501 { // not implemented
                Diagnostic.routeResponseStatusNotImplemented(context: context, node: function.calledExpression)
            }
        }
        return results
    }
    #endif
}

extension StaticRoute {
    #if StaticMiddleware
        public mutating func responses(
            routerStorage: RouterStorage,
            middleware: [StaticMiddleware]
        ) -> [IntermediateHTTPMessage] {
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
            return Self.responses(
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
        public mutating func responses() -> HTTPResponseMessage {
            var headers = HTTPHeaders()
            if body?.hasDateHeader ?? false {
                headers["date"] = HTTPDateFormat.placeholder
            }
            headers["content-type"] = nil
            headers["content-length"] = nil
            #if HTTPCooke
            return Self.responses(version: version, status: status, headers: &headers, cookies: [], body: body, contentType: contentType, charset: charset)
            #else
            return Self.responses(version: version, status: status, headers: &headers, body: body, contentType: contentType, charset: charset)
            #endif
        }
    #endif
}

// MARK: Static
extension StaticRoute {
    #if HTTPCookie
    package static func responses(
        routerStorage: RouterStorage,

        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: inout HTTPHeaders,
        cookies: [HTTPCookie],
        body: inout IntermediateResponseBody?,
        contentType: String?,
        charset: Charset?
    ) -> [IntermediateHTTPMessage] {
        headers["content-type"] = nil
        headers["content-length"] = nil

        var head = HTTPResponseMessageHead(headers: headers, cookies: cookies, status: status, version: version)
        var messages = [IntermediateHTTPMessage]()
        var varyCompression = [IntermediateHTTPMessage]()

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
                    head.headers["content-encoding"] = algorithm.acceptEncodingName
                    head.headers["vary"] = "Accept-Encoding"
                    body!.rawValue = compressed
                    if case let .string(isNonCopyable, isStatic, withDateHeader, _) = body!.type {
                        body!.type = .string(isNonCopyable: isNonCopyable, isStatic: isStatic, withDateHeader: withDateHeader, withCompressedBody: true)
                    }

                    if !routerStorage.settings.compression.compressOnlyIfResultIsSmaller {
                        varyCompression.append(.init(
                            head: head,
                            body: body,
                            contentType: contentType,
                            charset: charset,
                            vary: [.acceptEncoding]
                        ))
                    }
                }
            }
        }
        #endif

        messages.append(contentsOf: varyCompression)
        if messages.isEmpty {
            messages.append(.init(
                head: head,
                body: body,
                contentType: contentType,
                charset: charset
            ))
        }

        return messages
    }
    #else
    package static func responses(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: inout HTTPHeaders,
        body: IntermediateResponseBody?,
        contentType: String?,
        charset: Charset?
    ) -> [HTTPResponseMessage] {
        headers["content-type"] = nil
        headers["content-length"] = nil
        return [
            HTTPResponseMessage(
                head: .init(headers: headers, status: status, version: version),
                body: body,
                contentType: contentType,
                charset: charset
            )
        ]
    }
    #endif
}