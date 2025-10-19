
import DestinyBlueprint
import DestinyDefaults

/// Convenient route storage used by the macros to optimally manage routes.
public struct Route: Sendable {
    public var path:[PathComponent]
    public let contentType:String?

    public var defaultResponse:DynamicResponse
    public let handler:(@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)?
    @usableFromInline package var handlerDebugDescription:String? = nil

    public let isCaseSensitive:Bool
    public var method:HTTPRequestMethod
    public let status:HTTPResponseStatus.Code
    public let charset:Charset?
    public let version:HTTPVersion
}

// MARK: Init
extension Route {
    #if HTTPCookie
    public init(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        headers: HTTPHeaders = .init(),
        cookies: [HTTPCookie] = [],
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) {
        self.init(
            version: version,
            method: .init(method),
            path: path,
            isCaseSensitive: isCaseSensitive,
            status: status,
            contentType: contentType,
            charset: charset,
            headers: headers,
            cookies: cookies,
            body: body,
            handler: handler
        )
    }
    public init(
        version: HTTPVersion = .v1_1,
        method: HTTPRequestMethod,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        headers: HTTPHeaders = .init(),
        cookies: [HTTPCookie] = [],
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) {
        self.version = version
        self.method = method
        self.path = path
        self.isCaseSensitive = isCaseSensitive
        self.status = status
        self.contentType = contentType
        self.charset = charset
        self.defaultResponse = DynamicResponse.init(
            message: HTTPResponseMessage(
                version: version,
                status: status,
                headers: headers,
                cookies: cookies,
                body: body,
                contentType: contentType,
                charset: charset
            ),
            parameters: []
        )
        self.handler = handler
    }
    #else
    public init(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) {
        self.init(
            version: version,
            method: .init(method),
            path: path,
            isCaseSensitive: isCaseSensitive,
            status: status,
            contentType: contentType,
            charset: charset,
            headers: headers,
            body: body,
            handler: handler
        )
    }
    public init(
        version: HTTPVersion = .v1_1,
        method: HTTPRequestMethod,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) {
        self.version = version
        self.method = method
        self.path = path
        self.isCaseSensitive = isCaseSensitive
        self.status = status
        self.contentType = contentType
        self.charset = charset
        self.defaultResponse = DynamicResponse.init(
            message: HTTPResponseMessage(
                version: version,
                status: status,
                headers: headers,
                body: body,
                contentType: contentType,
                charset: charset
            ),
            parameters: []
        )
        self.handler = handler
    }
    #endif
}

// MARK: Conformances
extension Route: RouteProtocol {}