
import DestinyBlueprint
import DestinyDefaults
import DestinyEmbedded
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: StaticRoute
/// Default Static Route implementation where a complete HTTP Message is computed at compile time.
public struct StaticRoute: Sendable {
    public var path:[String]
    public let contentType:String?
    public let body:IntermediateResponseBody?

    public var method:HTTPRequestMethod
    public let status:HTTPResponseStatus.Code
    public let isCaseSensitive:Bool
    public let charset:Charset?
    public let version:HTTPVersion

    public init(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [String],
        isCaseSensitive: Bool = true,
        status: some HTTPResponseStatus.StorageProtocol,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: IntermediateResponseBody? = nil
    ) {
        self.init(
            version: version,
            method: method,
            path: path,
            isCaseSensitive: isCaseSensitive,
            status: status.code,
            contentType: contentType,
            charset: charset,
            body: body
        )
    }

    public init(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [String],
        isCaseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: IntermediateResponseBody? = nil
    ) {
        self.version = version
        self.method = .init(method)
        self.path = path
        self.isCaseSensitive = isCaseSensitive
        self.status = status
        self.contentType = contentType
        self.charset = charset
        self.body = body
    }
}

// MARK: Logic
extension StaticRoute {
    public var startLine: String {
        return "\(method.rawNameString()) /\(path.joined(separator: "/")) \(version.string)" 
    }

    public mutating func insertPath(contentsOf newElements: some Collection<String>, at i: Int) {
        path.insert(contentsOf: newElements, at: i)
    }
}

// MARK: Response
extension StaticRoute {
    #if StaticMiddleware
        public func response(
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
                body: body,
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
        public func response() -> HTTPResponseMessage {
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

    #if HTTPCookie
    @inline(__always)
    package static func response(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: inout HTTPHeaders,
        cookies: [HTTPCookie],
        body: IntermediateResponseBody?,
        contentType: String?,
        charset: Charset?
    ) -> HTTPResponseMessage {
        headers["content-type"] = nil
        headers["content-length"] = nil
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

// MARK: Responder
extension StaticRoute {
    #if StaticMiddleware
    public func responder(
        middleware: [StaticMiddleware]
    ) -> String? {
        return response(middleware: middleware).string(escapeLineBreak: true)
    }
    #else
    public func responder() -> String? {
        return response().string(escapeLineBreak: true)
    }
    #endif
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
    public func response(
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

// MARK: Responder
extension StaticRoute {
    /// The `RouteResponderProtocol` responder for this route.
    /// 
    /// - Parameters:
    ///   - context: Macro expansion context where it was called.
    ///   - function: `FunctionCallExprSyntax` that represents this route.
    ///   - middleware: Static middleware that this route will handle.
    #if StaticMiddleware
    public func responder(
        context: some MacroExpansionContext,
        function: FunctionCallExprSyntax,
        middleware: [StaticMiddleware]
    ) throws(HTTPMessageError) -> String? {
        return response(context: context, function: function, middleware: middleware).string(escapeLineBreak: true)
    }
    #else
    public func responder(
        context: some MacroExpansionContext,
        function: FunctionCallExprSyntax
    ) throws(HTTPMessageError) -> String? {
        return response(context: context, function: function).string(escapeLineBreak: true)
    }
    #endif
}