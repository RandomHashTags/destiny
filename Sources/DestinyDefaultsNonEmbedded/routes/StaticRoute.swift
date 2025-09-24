
import DestinyBlueprint
import DestinyDefaults

#if MediaTypes
import MediaTypes
#endif

// MARK: StaticRoute
/// Default Static Route implementation where a complete HTTP Message is computed at compile time.
public struct StaticRoute: StaticRouteProtocol {
    public var path:[String]
    public let contentType:String?
    public let body:(any ResponseBodyProtocol)?

    public let isCaseSensitive:Bool
    public var method:HTTPRequestMethod
    public let status:HTTPResponseStatus.Code
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
        method: some HTTPRequestMethodProtocol,
        path: [String],
        isCaseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: (any ResponseBodyProtocol)? = nil
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

    #if Inlinable
    @inlinable
    #endif
    public var startLine: String {
        return "\(method.rawNameString()) /\(path.joined(separator: "/")) \(version.string)" 
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func insertPath(contentsOf newElements: some Collection<String>, at i: Int) {
        path.insert(contentsOf: newElements, at: i)
    }
}

// MARK: Response
extension StaticRoute {
    #if StaticMiddleware
        public func response(
            middleware: [some StaticMiddlewareProtocol]
        ) -> some HTTPMessageProtocol {
            var version = version
            let path = path.joined(separator: "/")
            var status = status
            var contentType = contentType
            var headers = HTTPHeaders()
            if body?.hasDateHeader ?? false {
                headers["Date"] = HTTPDateFormat.placeholder
            }
            var cookies = [HTTPCookie]()
            middleware.forEach { middleware in
                if middleware.handles(version: version, path: path, method: method, contentType: contentType, status: status) {
                    middleware.apply(version: &version, contentType: &contentType, status: &status, headers: &headers, cookies: &cookies)
                }
            }
            headers[HTTPStandardResponseHeader.contentType.rawName] = nil
            headers[HTTPStandardResponseHeader.contentLength.rawName] = nil
            return Self.response(version: version, status: status, headers: &headers, cookies: cookies, body: body, contentType: contentType, charset: charset)
        }
    #else
        public func response() -> some HTTPMessageProtocol {
            var headers = HTTPHeaders()
            if body?.hasDateHeader ?? false {
                headers["Date"] = HTTPDateFormat.placeholder
            }
            headers[HTTPStandardResponseHeader.contentType.rawName] = nil
            headers[HTTPStandardResponseHeader.contentLength.rawName] = nil
            return Self.response(version: version, status: status, headers: &headers, cookies: [], body: body, contentType: contentType, charset: charset)
        }
    #endif

    @inline(__always)
    package static func response(
        version: HTTPVersion,
        status: HTTPResponseStatus.Code,
        headers: inout HTTPHeaders,
        cookies: [HTTPCookie],
        body: (any ResponseBodyProtocol)?,
        contentType: String?,
        charset: Charset?
    ) -> some HTTPMessageProtocol {
        headers[HTTPStandardResponseHeader.contentType.rawName] = nil
        headers[HTTPStandardResponseHeader.contentLength.rawName] = nil
        return HTTPResponseMessage(version: version, status: status, headers: headers, cookies: cookies, body: body, contentType: contentType, charset: charset)
    }
}




// MARK: Responder
extension StaticRoute {
    #if StaticMiddleware
    public func responder(
        middleware: [some StaticMiddlewareProtocol]
    ) throws(HTTPMessageError) -> (some StaticRouteResponderProtocol)? {
        return try response(middleware: middleware).string(escapeLineBreak: true)
    }
    #else
    public func responder() throws(HTTPMessageError) -> (some StaticRouteResponderProtocol)? {
        return try response().string(escapeLineBreak: true)
    }
    #endif
}

// MARK: Convenience inits





#if MediaTypes
// MARK: MediaTypes
extension StaticRoute {
    public init(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [String],
        isCaseSensitive: Bool = true,
        status: some HTTPResponseStatus.StorageProtocol,
        mediaType: (some MediaTypeProtocol)? = nil,
        charset: Charset? = nil,
        body: (any ResponseBodyProtocol)? = nil
    ) {
        self.init(
            version: version,
            method: method,
            path: path,
            isCaseSensitive: isCaseSensitive,
            status: status.code,
            contentType: mediaType?.template,
            charset: charset,
            body: body
        )
    }

    #if Copyable

        #if Inlinable
        @inlinable
        #endif
        public static func on(
            version: HTTPVersion = .v1_1,
            method: some HTTPRequestMethodProtocol,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: some ResponseBodyProtocol
        ) -> Self {
            return Self(version: version, method: method, path: path, isCaseSensitive: caseSensitive, status: status, contentType: mediaType?.template, charset: charset, body: body)
        }

        #if Inlinable
        @inlinable
        #endif
        public static func get(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: some ResponseBodyProtocol
        ) -> Self {
            return on(version: version, method: HTTPStandardRequestMethod.get, path: path, caseSensitive: caseSensitive, status: status, mediaType: mediaType, charset: charset, body: body)
        }

        #if Inlinable
        @inlinable
        #endif
        public static func post(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: some ResponseBodyProtocol
        ) -> Self {
            return on(version: version, method: HTTPStandardRequestMethod.post, path: path, caseSensitive: caseSensitive, status: status, mediaType: mediaType, charset: charset, body: body)
        }
    #endif

    #if NonCopyable

        #if Inlinable
        @inlinable
        #endif
        public static func on(
            version: HTTPVersion = .v1_1,
            method: some HTTPRequestMethodProtocol,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        #if Inlinable
        @inlinable
        #endif
        public static func get(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        #if Inlinable
        @inlinable
        #endif
        public static func post(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            mediaType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }
    #endif
}
#endif

#if Copyable
// MARK: Copyable
extension StaticRoute {
    #if Inlinable
    @inlinable
    #endif
    public static func on(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: some ResponseBodyProtocol
    ) -> Self {
        return Self(version: version, method: method, path: path, isCaseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    #if HTTPStandardRequestMethods

        #if Inlinable
        @inlinable
        #endif
        public static func get(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: some ResponseBodyProtocol
        ) -> Self {
            return on(version: version, method: HTTPStandardRequestMethod.get, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
        }

        #if Inlinable
        @inlinable
        #endif
        public static func head(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: some ResponseBodyProtocol
        ) -> Self {
            return on(version: version, method: HTTPStandardRequestMethod.head, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
        }

        #if Inlinable
        @inlinable
        #endif
        public static func post(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: some ResponseBodyProtocol
        ) -> Self {
            return on(version: version, method: HTTPStandardRequestMethod.post, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
        }

        #if Inlinable
        @inlinable
        #endif
        public static func put(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: some ResponseBodyProtocol
        ) -> Self {
            return on(version: version, method: HTTPStandardRequestMethod.put, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
        }

        #if Inlinable
        @inlinable
        #endif
        public static func delete(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: some ResponseBodyProtocol
        ) -> Self {
            return on(version: version, method: HTTPStandardRequestMethod.delete, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
        }

        #if Inlinable
        @inlinable
        #endif
        public static func connect(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: some ResponseBodyProtocol
        ) -> Self {
            return on(version: version, method: HTTPStandardRequestMethod.connect, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
        }

        #if Inlinable
        @inlinable
        #endif
        public static func options(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: some ResponseBodyProtocol
        ) -> Self {
            return on(version: version, method: HTTPStandardRequestMethod.options, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
        }

        #if Inlinable
        @inlinable
        #endif
        public static func trace(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: some ResponseBodyProtocol
        ) -> Self {
            return on(version: version, method: HTTPStandardRequestMethod.trace, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
        }

        #if Inlinable
        @inlinable
        #endif
        public static func patch(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: some ResponseBodyProtocol
        ) -> Self {
            return on(version: version, method: HTTPStandardRequestMethod.patch, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
        }
    #endif
}
#endif

#if NonCopyable
// MARK: NonCopyable
extension StaticRoute {
    #if Inlinable
    @inlinable
    #endif
    public static func on(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable
    ) -> Self {
        fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
    }

    #if HTTPStandardRequestMethods

        #if Inlinable
        @inlinable
        #endif
        public static func get(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        #if Inlinable
        @inlinable
        #endif
        public static func head(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        #if Inlinable
        @inlinable
        #endif
        public static func post(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        #if Inlinable
        @inlinable
        #endif
        public static func put(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        #if Inlinable
        @inlinable
        #endif
        public static func delete(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        #if Inlinable
        @inlinable
        #endif
        public static func connect(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        #if Inlinable
        @inlinable
        #endif
        public static func options(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        #if Inlinable
        @inlinable
        #endif
        public static func trace(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }

        #if Inlinable
        @inlinable
        #endif
        public static func patch(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
            contentType: String? = nil,
            charset: Charset? = nil,
            body: consuming some ResponseBodyProtocol & ~Copyable
        ) -> Self {
            fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
        }
    #endif
}
#endif