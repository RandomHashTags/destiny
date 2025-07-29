
import DestinyBlueprint

// MARK: DynamicRoute
/// Default Dynamic Route implementation where a complete HTTP Message, computed at compile time, is modified upon requests.
public struct DynamicRoute: DynamicRouteProtocol {
    /// Path of this route.
    public var path:[PathComponent]

    /// Default content type of this route. May be modified by static middleware at compile time or dynamic middleware upon requests.
    public var contentType:HTTPMediaType?

    /// Default HTTP Message computed by default values and static middleware.
    public var defaultResponse:DynamicResponse
    public let handler:@Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    @usableFromInline package var handlerDebugDescription:String = "{ _, _ in }"

    /// `HTTPVersion` associated with this route.
    public let version:HTTPVersion
    public var method:any HTTPRequestMethodProtocol

    /// Default status of this route. May be modified by static middleware at compile time or by dynamic middleware upon requests.
    public var status:HTTPResponseStatus.Code
    public let isCaseSensitive:Bool

    public init(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        headers: HTTPHeaders = .init(),
        cookies: [any HTTPCookieProtocol] = [],
        body: (any ResponseBodyProtocol)? = nil,
        handler: @escaping @Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) {
        self.version = version
        self.method = method
        self.path = path
        self.isCaseSensitive = isCaseSensitive
        self.status = status
        self.contentType = contentType
        self.defaultResponse = DynamicResponse.init(
            message: HTTPResponseMessage(version: version, status: status, headers: headers, cookies: cookies, body: body, contentType: nil, charset: nil),
            parameters: []
        )
        self.handler = handler
    }

    @inlinable
    public var pathCount: Int {
        path.count
    }

    @inlinable
    public var pathContainsParameters: Bool {
        path.firstIndex(where: { $0.isParameter }) == nil
    }

    @inlinable
    public func responder() -> any DynamicRouteResponderProtocol {
        DynamicRouteResponder(path: path, defaultResponse: defaultResponse, logic: handler, logicDebugDescription: handlerDebugDescription)
    }

    @inlinable
    public mutating func applyStaticMiddleware(_ middleware: [some StaticMiddlewareProtocol]) {
        let path = path.map({ $0.slug }).joined(separator: "/")
        for middleware in middleware {
            if middleware.handles(
                version: defaultResponse.message.version,
                path: path,
                method: method,
                contentType: contentType,
                status: status
            ) {
                middleware.apply(contentType: &contentType, to: &defaultResponse)
            }
        }
    }

    @inlinable
    public func startLine() -> String {
        return method.rawNameString() + " /" + path.map({ $0.slug }).joined(separator: "/") + " " + version.string
    }
}

// MARK: Convenience inits
extension DynamicRoute {
    @inlinable
    public static func on(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @escaping @Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return Self(version: version, method: method, path: path, isCaseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    @inlinable
    public static func get(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @escaping @Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.get, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    @inlinable
    public static func head(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @escaping @Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.head, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    @inlinable
    public static func post(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @escaping @Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.post, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    @inlinable
    public static func put(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @escaping @Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.put, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    @inlinable
    public static func delete(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @escaping @Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.delete, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    @inlinable
    public static func connect(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @escaping @Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.connect, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    @inlinable
    public static func options(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @escaping @Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.options, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    @inlinable
    public static func trace(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @escaping @Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.trace, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    @inlinable
    public static func patch(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @escaping @Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod.patch, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }
}