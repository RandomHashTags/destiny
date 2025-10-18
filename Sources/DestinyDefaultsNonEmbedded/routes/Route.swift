
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

// MARK: Convenience
extension Route {
    #if Inlinable
    @inlinable
    #endif
    public static func on(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return Self(version: version, method: method, path: path, isCaseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func get(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.get, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func head(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.head, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func post(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.post, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func put(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.put, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func delete(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.delete, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func connect(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.connect, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func options(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.options, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func trace(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.trace, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func patch(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.patch, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, headers: headers, body: body, handler: handler)
    }
}

// MARK: Conformances
extension Route: RouteProtocol {}



#if MediaTypes
// MARK: MediaTypes
import MediaTypes
extension Route {
    #if HTTPCookie
        public init(
            version: HTTPVersion = .v1_1,
            method: some HTTPRequestMethodProtocol,
            path: [PathComponent],
            isCaseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            mediaType: MediaType? = nil,
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
                contentType: mediaType?.template,
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
            mediaType: MediaType? = nil,
            headers: HTTPHeaders = .init(),
            cookies: [HTTPCookie] = [],
            body: (any ResponseBodyProtocol)? = nil,
            handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
        ) {
            self.init(
                version: version,
                method: method,
                path: path,
                isCaseSensitive: isCaseSensitive,
                status: status,
                contentType: mediaType?.template,
                headers: headers,
                cookies: cookies,
                body: body,
                handler: handler
            )
        }
    #else
        public init(
            version: HTTPVersion = .v1_1,
            method: some HTTPRequestMethodProtocol,
            path: [PathComponent],
            isCaseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            mediaType: MediaType? = nil,
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
                contentType: mediaType?.template,
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
            mediaType: MediaType? = nil,
            headers: HTTPHeaders = .init(),
            body: (any ResponseBodyProtocol)? = nil,
            handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
        ) {
            self.init(
                version: version,
                method: method,
                path: path,
                isCaseSensitive: isCaseSensitive,
                status: status,
                contentType: mediaType?.template,
                headers: headers,
                body: body,
                handler: handler
            )
        }
    #endif

    #if Inlinable
    @inlinable
    #endif
    public static func on(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: MediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return Self(version: version, method: method, path: path, isCaseSensitive: caseSensitive, status: status, contentType: mediaType?.template, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func on(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: (some MediaTypeProtocol)? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return Self(version: version, method: method, path: path, isCaseSensitive: caseSensitive, status: status, contentType: mediaType?.template, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func get(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: MediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.get, path: path, caseSensitive: caseSensitive, status: status, mediaType: mediaType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func get(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: (some MediaTypeProtocol)? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.get, path: path, caseSensitive: caseSensitive, status: status, mediaType: mediaType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func head(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: MediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.head, path: path, caseSensitive: caseSensitive, status: status, mediaType: mediaType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func post(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: MediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.post, path: path, caseSensitive: caseSensitive, status: status, mediaType: mediaType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func put(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: MediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.put, path: path, caseSensitive: caseSensitive, status: status, mediaType: mediaType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func delete(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: MediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.delete, path: path, caseSensitive: caseSensitive, status: status, mediaType: mediaType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func connect(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: MediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.connect, path: path, caseSensitive: caseSensitive, status: status, mediaType: mediaType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func options(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: MediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.options, path: path, caseSensitive: caseSensitive, status: status, mediaType: mediaType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func trace(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: MediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.trace, path: path, caseSensitive: caseSensitive, status: status, mediaType: mediaType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func patch(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: MediaType? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.patch, path: path, caseSensitive: caseSensitive, status: status, mediaType: mediaType, headers: headers, body: body, handler: handler)
    }
}
#endif

#if NonCopyable
// MARK: NonCopyable
extension Route {
    public static func on(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
    }

    public static func get(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
    }

    public static func head(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
    }

    public static func post(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
    }

    public static func put(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
    }

    public static func delete(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
    }

    public static func connect(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
    }

    public static func options(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
    }

    public static func trace(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
    }

    public static func patch(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
    }

    #if MediaTypes
        public static func on(
            version: HTTPVersion = .v1_1,
            method: some HTTPRequestMethodProtocol,
            path: [PathComponent],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            mediaType: MediaType? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable,
            handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }
        public static func on(
            version: HTTPVersion = .v1_1,
            method: some HTTPRequestMethodProtocol,
            path: [PathComponent],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable,
            handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        public static func get(
            version: HTTPVersion = .v1_1,
            path: [PathComponent],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable,
            handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        public static func head(
            version: HTTPVersion = .v1_1,
            path: [PathComponent],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable,
            handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        public static func post(
            version: HTTPVersion = .v1_1,
            path: [PathComponent],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable,
            handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        public static func put(
            version: HTTPVersion = .v1_1,
            path: [PathComponent],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable,
            handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        public static func delete(
            version: HTTPVersion = .v1_1,
            path: [PathComponent],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable,
            handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        public static func connect(
            version: HTTPVersion = .v1_1,
            path: [PathComponent],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable,
            handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        public static func options(
            version: HTTPVersion = .v1_1,
            path: [PathComponent],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable,
            handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        public static func trace(
            version: HTTPVersion = .v1_1,
            path: [PathComponent],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable,
            handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        public static func patch(
            version: HTTPVersion = .v1_1,
            path: [PathComponent],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable,
            handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }
    #endif
}
#endif