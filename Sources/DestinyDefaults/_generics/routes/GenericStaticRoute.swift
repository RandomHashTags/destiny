
#if GenericStaticRoute

import DestinyEmbedded

// MARK: StaticRoute
/// Default Static Route implementation where a complete HTTP Message is computed at compile time.
public struct GenericStaticRoute<
        Body: ResponseBodyProtocol
    > {
    public var path:[String]
    public let contentType:String?
    public let body:Body?

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
        body: Body? = nil
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
        body: Body? = nil
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

    /// Insert paths into this route's path at the given index.
    /// 
    /// Used by Route Groups at compile time.
    #if Inlinable
    @inlinable
    #endif
    public mutating func insertPath(contentsOf newElements: some Collection<String>, at i: Int) {
        path.insert(contentsOf: newElements, at: i)
    }
}

    #if StaticMiddleware

    // MARK: Response
    extension GenericStaticRoute {
        public func response(
            middleware: some StaticMiddlewareStorageProtocol
        ) -> some GenericHTTPMessageProtocol {
            var version = version
            let path = path.joined(separator: "/")
            var status = status
            var contentType = contentType
            var headers = HTTPHeaders()
            if body?.hasDateHeader ?? false {
                headers["date"] = HTTPDateFormat.placeholder
            }
            var cookies = [HTTPCookie]()
            middleware.forEach { middleware in
                if middleware.handles(version: version, path: path, method: method, contentType: contentType, status: status) {
                    middleware.apply(version: &version, contentType: &contentType, status: &status, headers: &headers, cookies: &cookies)
                }
            }
            headers["content-type"] = nil
            headers["content-length"] = nil
            return GenericHTTPResponseMessage(version: version, status: status, headers: headers, cookies: cookies, body: body, contentType: contentType, charset: charset)
        }
    }

    // MARK: Responder
    extension GenericStaticRoute {
        public func responder(
            middleware: some StaticMiddlewareStorageProtocol
        ) throws(HTTPMessageError) -> (some StaticRouteResponderProtocol)? {
            return try response(middleware: middleware).string(escapeLineBreak: true)
        }
    }

    #endif

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension GenericStaticRoute: RouteProtocol {}

#endif

// MARK: Convenience inits
extension GenericStaticRoute {
    #if Inlinable
    @inlinable
    #endif
    public static func on(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: Body,
    ) -> Self {
        return Self(version: version, method: method, path: path, isCaseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func get(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: Body,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod(name: "GET"), path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func head(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: Body,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod(name: "HEAD"), path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func post(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: Body,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod(name: "POST"), path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func put(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: Body,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod(name: "PUT"), path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func delete(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: Body,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod(name: "DELETE"), path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func connect(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: Body,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod(name: "CONNECT"), path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func options(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: Body,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod(name: "OPTIONS"), path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func trace(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: Body,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod(name: "TRACE"), path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func patch(
        version: HTTPVersion = .v1_1,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: Body,
    ) -> Self {
        return on(version: version, method: HTTPRequestMethod(name: "PATCH"), path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }
}

    #if MediaTypes
    // MARK: MediaTypes
    import MediaTypes

    extension GenericStaticRoute {
        public init(
            version: HTTPVersion = .v1_1,
            method: some HTTPRequestMethodProtocol,
            path: [String],
            isCaseSensitive: Bool = true,
            status: some HTTPResponseStatus.StorageProtocol,
            contentType: MediaType? = nil,
            charset: Charset? = nil,
            body: Body? = nil
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
            status: some HTTPResponseStatus.StorageProtocol,
            contentType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: Body? = nil
        ) {
            let mediaType:MediaType?
            if let contentType {
                mediaType = .init(contentType)
            } else {
                mediaType = nil
            }
            self.init(
                version: version,
                method: method,
                path: path,
                isCaseSensitive: isCaseSensitive,
                status: status.code,
                contentType: mediaType,
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
            contentType: MediaType? = nil,
            charset: Charset? = nil,
            body: Body? = nil
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
        public static func on(
            version: HTTPVersion = .v1_1,
            method: some HTTPRequestMethodProtocol,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            contentType: MediaType? = nil,
            charset: Charset? = nil,
            body: Body
        ) -> Self {
            return Self(version: version, method: method, path: path, isCaseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
        }

        #if Inlinable
        @inlinable
        #endif
        public static func on(
            version: HTTPVersion = .v1_1,
            method: some HTTPRequestMethodProtocol,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            contentType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: Body
        ) -> Self {
            let mediaType:MediaType?
            if let contentType {
                mediaType = .init(contentType)
            } else {
                mediaType = nil
            }
            return Self(version: version, method: method, path: path, isCaseSensitive: caseSensitive, status: status, contentType: mediaType, charset: charset, body: body)
        }

        #if Inlinable
        @inlinable
        #endif
        public static func get(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            contentType: MediaType? = nil,
            charset: Charset? = nil,
            body: Body
        ) -> Self {
            return on(version: version, method: HTTPStandardRequestMethod.get, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
        }

        #if Inlinable
        @inlinable
        #endif
        public static func get(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            contentType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: Body
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
            status: HTTPResponseStatus.Code = 501, // not implemented
            contentType: MediaType? = nil,
            charset: Charset? = nil,
            body: Body
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
            status: HTTPResponseStatus.Code = 501, // not implemented
            contentType: MediaType? = nil,
            charset: Charset? = nil,
            body: Body
        ) -> Self {
            return on(version: version, method: HTTPStandardRequestMethod.post, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
        }

        #if Inlinable
        @inlinable
        #endif
        public static func post(
            version: HTTPVersion = .v1_1,
            path: [String],
            caseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            contentType: (some MediaTypeProtocol)? = nil,
            charset: Charset? = nil,
            body: Body
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
            status: HTTPResponseStatus.Code = 501, // not implemented
            contentType: MediaType? = nil,
            charset: Charset? = nil,
            body: Body
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
            status: HTTPResponseStatus.Code = 501, // not implemented
            contentType: MediaType? = nil,
            charset: Charset? = nil,
            body: Body
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
            status: HTTPResponseStatus.Code = 501, // not implemented
            contentType: MediaType? = nil,
            charset: Charset? = nil,
            body: Body
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
            status: HTTPResponseStatus.Code = 501, // not implemented
            contentType: MediaType? = nil,
            charset: Charset? = nil,
            body: Body
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
            status: HTTPResponseStatus.Code = 501, // not implemented
            contentType: MediaType? = nil,
            charset: Charset? = nil,
            body: Body
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
            status: HTTPResponseStatus.Code = 501, // not implemented
            contentType: MediaType? = nil,
            charset: Charset? = nil,
            body: Body
        ) -> Self {
            return on(version: version, method: HTTPStandardRequestMethod.patch, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
        }
    }
    #endif

#endif