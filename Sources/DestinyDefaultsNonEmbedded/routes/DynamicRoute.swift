
import DestinyBlueprint
import DestinyDefaults

// MARK: DynamicRoute
/// Default Dynamic Route implementation where a complete HTTP Message, computed at compile time, is modified upon requests.
public struct DynamicRoute: DynamicRouteProtocol {
    /// Path of this route.
    public var path:[PathComponent]

    /// Default content type of this route. May be modified by static middleware at compile time or dynamic middleware upon requests.
    public var contentType:String?

    /// Default HTTP Message computed by default values and static middleware.
    public var defaultResponse:DynamicResponse
    public let handler:@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    @usableFromInline package var handlerDebugDescription:String = "{ _, _ in }"

    /// `HTTPVersion` associated with this route.
    public let version:HTTPVersion
    public var method:HTTPRequestMethod

    /// Default status of this route. May be modified by static middleware at compile time or by dynamic middleware upon requests.
    public var status:HTTPResponseStatus.Code
    public let isCaseSensitive:Bool

    #if Inlinable
    @inlinable
    #endif
    public var pathCount: Int {
        path.count
    }

    #if Inlinable
    @inlinable
    #endif
    public var pathContainsParameters: Bool {
        path.firstIndex(where: { $0.isParameter }) == nil
    }

    #if Inlinable
    @inlinable
    #endif
    public func startLine() -> String {
        return "\(method.rawNameString()) /\(path.map({ $0.slug }).joined(separator: "/")) \(version.string)" 
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func insertPath(contentsOf newElements: some Collection<PathComponent>, at i: Int) {
        path.insert(contentsOf: newElements, at: i)
    }
}

// MARK: Init
extension DynamicRoute {
    public init(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: String? = nil,
        headers: HTTPHeaders = .init(),
        cookies: [HTTPCookie] = [],
        body: (any ResponseBodyProtocol)? = nil,
        handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) {
        self.init(
            version: version,
            method: .init(method),
            path: path,
            isCaseSensitive: isCaseSensitive,
            status: status,
            contentType: contentType,
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
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: String? = nil,
        headers: HTTPHeaders = .init(),
        cookies: [HTTPCookie] = [],
        body: (any ResponseBodyProtocol)? = nil,
        handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) {
        self.version = version
        self.method = method
        self.path = path
        self.isCaseSensitive = isCaseSensitive
        self.status = status
        self.contentType = contentType
        self.defaultResponse = DynamicResponse.init(
            message: HTTPResponseMessage(
                version: version,
                status: status,
                headers: headers,
                cookies: cookies,
                body: body,
                contentType: nil,
                charset: nil
            ),
            parameters: []
        )
        self.handler = handler
    }
}

#if StaticMiddleware
    // MARK: Apply static middleware
    extension DynamicRoute {
        #if Inlinable
        @inlinable
        #endif
        public mutating func applyStaticMiddleware(_ middleware: [some StaticMiddlewareProtocol]) throws(AnyError) {
            let path = path.map({ $0.slug }).joined(separator: "/")
            for middleware in middleware {
                if middleware.handles(
                    version: defaultResponse.message.version,
                    path: path,
                    method: method,
                    contentType: contentType,
                    status: status
                ) {
                    try middleware.apply(contentType: &contentType, to: &defaultResponse)
                }
            }
        }
    }
#endif

// MARK: Convenience inits
extension DynamicRoute {
    #if Inlinable
    @inlinable
    #endif
    public static func on(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: String? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return Self(version: version, method: method, path: path, isCaseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func get(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: String? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.get, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func head(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: String? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.head, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func post(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: String? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.post, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func put(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: String? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.put, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func delete(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: String? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.delete, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func connect(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: String? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.connect, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func options(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: String? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.options, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func trace(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: String? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.trace, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func patch(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: String? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.patch, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, body: body, handler: handler)
    }
}

#if MediaTypes
    // MARK: MediaTypes
    import MediaTypes
    extension DynamicRoute {
        public init(
            version: HTTPVersion = .v1_1,
            method: some HTTPRequestMethodProtocol,
            path: [PathComponent],
            isCaseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: MediaType? = nil,
            headers: HTTPHeaders = .init(),
            cookies: [HTTPCookie] = [],
            body: (any ResponseBodyProtocol)? = nil,
            handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
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
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: MediaType? = nil,
            headers: HTTPHeaders = .init(),
            cookies: [HTTPCookie] = [],
            body: (any ResponseBodyProtocol)? = nil,
            handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
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

        #if Inlinable
        @inlinable
        #endif
        public static func on(
            version: HTTPVersion = .v1_1,
            method: some HTTPRequestMethodProtocol,
            path: [PathComponent],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: MediaType? = nil,
            headers: HTTPHeaders = .init(),
            body: (any ResponseBodyProtocol)? = nil,
            handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
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
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: (some MediaTypeProtocol)? = nil,
            headers: HTTPHeaders = .init(),
            body: (any ResponseBodyProtocol)? = nil,
            handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
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
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: MediaType? = nil,
            headers: HTTPHeaders = .init(),
            body: (any ResponseBodyProtocol)? = nil,
            handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
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
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: (some MediaTypeProtocol)? = nil,
            headers: HTTPHeaders = .init(),
            body: (any ResponseBodyProtocol)? = nil,
            handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
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
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: MediaType? = nil,
            headers: HTTPHeaders = .init(),
            body: (any ResponseBodyProtocol)? = nil,
            handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
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
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: MediaType? = nil,
            headers: HTTPHeaders = .init(),
            body: (any ResponseBodyProtocol)? = nil,
            handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
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
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: MediaType? = nil,
            headers: HTTPHeaders = .init(),
            body: (any ResponseBodyProtocol)? = nil,
            handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
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
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: MediaType? = nil,
            headers: HTTPHeaders = .init(),
            body: (any ResponseBodyProtocol)? = nil,
            handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
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
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: MediaType? = nil,
            headers: HTTPHeaders = .init(),
            body: (any ResponseBodyProtocol)? = nil,
            handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
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
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: MediaType? = nil,
            headers: HTTPHeaders = .init(),
            body: (any ResponseBodyProtocol)? = nil,
            handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
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
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: MediaType? = nil,
            headers: HTTPHeaders = .init(),
            body: (any ResponseBodyProtocol)? = nil,
            handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
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
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: MediaType? = nil,
            headers: HTTPHeaders = .init(),
            body: (any ResponseBodyProtocol)? = nil,
            handler: @Sendable @escaping (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void
        ) -> Self {
            return on(version: version, method: HTTPStandardRequestMethod.patch, path: path, caseSensitive: caseSensitive, status: status, mediaType: mediaType, headers: headers, body: body, handler: handler)
        }
    }
#endif