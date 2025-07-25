
import DestinyBlueprint
import OrderedCollections

// MARK: StaticRoute
/// Default Static Route implementation where a complete HTTP Message is computed at compile time.
public struct StaticRoute: StaticRouteProtocol {
    public var path:[String]
    public let contentType:HTTPMediaType?
    public let body:(any ResponseBodyProtocol)?

    public let version:HTTPVersion
    public var method:any HTTPRequestMethodProtocol
    public let status:HTTPResponseStatus.Code
    public let charset:Charset?
    public let isCaseSensitive:Bool

    public init<T: HTTPResponseStatus.StorageProtocol>(
        version: HTTPVersion = .v1_1,
        method: any HTTPRequestMethodProtocol,
        path: [String],
        isCaseSensitive: Bool = true,
        status: T,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: (any ResponseBodyProtocol)? = nil
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
        method: any HTTPRequestMethodProtocol,
        path: [String],
        isCaseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: (any ResponseBodyProtocol)? = nil
    ) {
        self.version = version
        self.method = method
        self.path = path
        self.isCaseSensitive = isCaseSensitive
        self.status = status
        self.contentType = contentType
        self.charset = charset
        self.body = body
    }

    @inlinable
    public var startLine: String {
        return method.rawNameString() + " /" + path.joined(separator: "/") + " " + version.string
    }

    @inlinable
    public mutating func insertPath<C: Collection<String>>(contentsOf newElements: C, at i: Int) {
        path.insert(contentsOf: newElements, at: i)
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)

#if canImport(SwiftDiagnostics)
import SwiftDiagnostics
#endif

import SwiftSyntax
import SwiftSyntaxMacros

// MARK: SwiftSyntax
extension StaticRoute {
    public func response(
        context: MacroExpansionContext?,
        function: FunctionCallExprSyntax?,
        middleware: [any StaticMiddlewareProtocol]
    ) -> any HTTPMessageProtocol {
        var version = version
        let path = path.joined(separator: "/")
        var status = status
        var contentType = contentType
        var headers = OrderedDictionary<String, String>()
        if body?.hasDateHeader ?? false {
            headers["Date"] = HTTPDateFormat.placeholder
        }
        var cookies:[any HTTPCookieProtocol] = []
        for middleware in middleware {
            if middleware.handles(version: version, path: path, method: method, contentType: contentType, status: status) {
                middleware.apply(version: &version, contentType: &contentType, status: &status, headers: &headers, cookies: &cookies)
            }
        }
        if let context, let function, status == HTTPResponseStatus.notImplemented.code {
            #if canImport(SwiftDiagnostics)
            Diagnostic.routeResponseStatusNotImplemented(context: context, node: function.calledExpression)
            #endif
        }
        headers[HTTPResponseHeader.contentType.rawNameString] = nil
        headers[HTTPResponseHeader.contentLength.rawNameString] = nil
        return HTTPResponseMessage(version: version, status: status, headers: headers, cookies: cookies, body: body, contentType: contentType, charset: charset)
    }

    @inlinable
    public func responder(context: MacroExpansionContext?, function: FunctionCallExprSyntax?, middleware: [any StaticMiddlewareProtocol]) throws -> (any StaticRouteResponderProtocol)? {
        return try response(context: context, function: function, middleware: middleware).string(escapeLineBreak: true)
    }
}

extension StaticRoute {
    public static func parse(context: some MacroExpansionContext, version: HTTPVersion, _ function: FunctionCallExprSyntax) -> Self? {
        var version = version
        var method:any HTTPRequestMethodProtocol = HTTPRequestMethod.get
        var path = [String]()
        var isCaseSensitive = true
        var status = HTTPResponseStatus.notImplemented.code
        var contentType = HTTPMediaType.textPlain
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
                status = HTTPResponseStatus.parse(expr: argument.expression)?.code ?? status
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
#endif

// MARK: Convenience inits
extension StaticRoute {
    @inlinable
    public static func on(
        version: HTTPVersion = .v1_1,
        method: any HTTPRequestMethodProtocol,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
    ) -> Self {
        return Self(version: version, method: method, path: path, isCaseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    @inlinable
    public static func get(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.get, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    @inlinable
    public static func head(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.head, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    @inlinable
    public static func post(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.post, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    @inlinable
    public static func put(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.put, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    @inlinable
    public static func delete(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.delete, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    @inlinable
    public static func connect(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.connect, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    @inlinable
    public static func options(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.options, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    @inlinable
    public static func trace(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.trace, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    @inlinable
    public static func patch(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.patch, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }
}