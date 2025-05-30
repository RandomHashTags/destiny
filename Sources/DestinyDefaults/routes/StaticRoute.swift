
import DestinyBlueprint
import OrderedCollections
import SwiftCompression
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: StaticRoute
/// Default Static Route implementation where a complete HTTP Message is computed at compile time.
public struct StaticRoute: StaticRouteProtocol {
    public var path:[String]
    public let contentType:HTTPMediaType?
    public let body:(any ResponseBodyProtocol)?
    public var supportedCompressionAlgorithms:Set<CompressionAlgorithm>

    public let version:HTTPVersion
    public var method:HTTPRequestMethod
    public let status:HTTPResponseStatus.Code
    public let charset:Charset?
    public let isCaseSensitive:Bool

    public init<T: HTTPResponseStatus.StorageProtocol>(
        version: HTTPVersion = .v1_0,
        method: HTTPRequestMethod,
        path: [StaticString],
        isCaseSensitive: Bool = true,
        status: T,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) {
        self.init(
            version: version,
            method: method,
            path: path,
            isCaseSensitive: isCaseSensitive,
            status: status.code,
            contentType: contentType,
            charset: charset,
            body: body,
            supportedCompressionAlgorithms: supportedCompressionAlgorithms
        )
    }
    public init(
        version: HTTPVersion = .v1_0,
        method: HTTPRequestMethod,
        path: [StaticString],
        isCaseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) {
        self.version = version
        self.method = method
        self.path = path.map({ $0.description })
        self.isCaseSensitive = isCaseSensitive
        self.status = status
        self.contentType = contentType
        self.charset = charset
        self.body = body
        self.supportedCompressionAlgorithms = supportedCompressionAlgorithms
    }

    @inlinable
    public var startLine: String {
        return method.rawName.string() + " /" + path.joined(separator: "/") + " " + version.string
    }

    @inlinable
    public mutating func insertPath<C: Collection<String>>(contentsOf newElements: C, at i: Int) {
        path.insert(contentsOf: newElements, at: i)
    }

    public var debugDescription: String {
        """
        StaticRoute(
            version: .\(version),
            method: \(method.debugDescription),
            path: \(path),
            isCaseSensitive: \(isCaseSensitive),
            status: \(status),
            contentType: \(contentType.debugDescription),
            charset: \(charset?.debugDescription ?? "nil"),
            body: \(body?.debugDescription ?? "nil"),
            supportedCompressionAlgorithms: [\(supportedCompressionAlgorithms.map({ "." + $0.rawValue }).joined(separator: ","))]
        )
        """
    }

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
        if let id = body?.id,
                (id == ResponseBody.StringWithDateHeader.id
                || id == ResponseBody.StaticStringWithDateHeader.id
                || id == ResponseBody.MacroExpansionWithDateHeader<String>.id) {
            headers["Date"] = "Thu, 01 Jan 1970 00:00:00 GMT"
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
        let body = try response(context: context, function: function, middleware: middleware).string(escapeLineBreak: true, fromMacro: context != nil)
        return RouteResponses.String(body)
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension StaticRoute {
    public static func parse(context: some MacroExpansionContext, version: HTTPVersion, _ function: FunctionCallExprSyntax) -> Self? {
        var version = version
        var method = HTTPRequestMethod.get
        var path = [String]()
        var isCaseSensitive = true
        var status = HTTPResponseStatus.notImplemented.code
        var contentType = HTTPMediaType.textPlain
        var charset:Charset? = nil
        var body:(any ResponseBodyProtocol)? = nil
        var supportedCompressionAlgorithms:Set<CompressionAlgorithm> = []
        for argument in function.arguments {
            switch argument.label?.text {
            case "version":
                version = HTTPVersion.parse(argument.expression) ?? version
            case "method":
                method = HTTPRequestMethod(expr: argument.expression) ?? method
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
                body = ResponseBody.parse(expr: argument.expression) ?? body
            case "supportedCompressionAlgorithms":
                supportedCompressionAlgorithms = Set(argument.expression.array!.elements.compactMap({ CompressionAlgorithm.parse($0.expression) }))
            default:
                break
            }
        }
        var route = StaticRoute(
            version: version,
            method: method,
            path: [],
            isCaseSensitive: isCaseSensitive,
            status: status,
            contentType: contentType,
            charset: charset,
            body: body,
            supportedCompressionAlgorithms: supportedCompressionAlgorithms
        )
        if isCaseSensitive {
            route.path = path
        } else {
            route.path = path.map({ $0.lowercased() })
        }
        return route
    }
}
#endif

// MARK: Convenience inits
extension StaticRoute {
    @inlinable
    public static func on(
        version: HTTPVersion = .v1_0,
        method: HTTPRequestMethod,
        path: [StaticString],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return Self(version: version, method: method, path: path, isCaseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func get(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .get, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func head(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .head, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func post(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .post, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func put(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .put, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func delete(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .delete, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func connect(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .connect, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func options(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .options, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func trace(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .trace, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func patch(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: any ResponseBodyProtocol,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .patch, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }
}