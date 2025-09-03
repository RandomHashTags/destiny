
import DestinyBlueprint

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

    public init(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [String],
        isCaseSensitive: Bool = true,
        status: some HTTPResponseStatus.StorageProtocol,
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
        method: some HTTPRequestMethodProtocol,
        path: [String],
        isCaseSensitive: Bool = true,
        status: some HTTPResponseStatus.StorageProtocol,
        contentType: (some HTTPMediaTypeProtocol)? = nil,
        charset: Charset? = nil,
        body: (any ResponseBodyProtocol)? = nil
    ) {
        let mediaType:HTTPMediaType?
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
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
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
    public func response(
        middleware: some StaticMiddlewareStorageProtocol
    ) -> some HTTPMessageProtocol {
        var version = version
        let path = path.joined(separator: "/")
        var status = status
        var contentType = contentType
        var headers = HTTPHeaders()
        if body?.hasDateHeader ?? false {
            headers["Date"] = HTTPDateFormat.placeholder
        }
        var cookies = [any HTTPCookieProtocol]()
        middleware.forEach { middleware in
            if middleware.handles(version: version, path: path, method: method, contentType: contentType, status: status) {
                middleware.apply(version: &version, contentType: &contentType, status: &status, headers: &headers, cookies: &cookies)
            }
        }
        headers[HTTPStandardResponseHeader.contentType.rawName] = nil
        headers[HTTPStandardResponseHeader.contentLength.rawName] = nil
        return HTTPResponseMessage(version: version, status: status, headers: headers, cookies: cookies, body: body, contentType: contentType, charset: charset)
    }
}

// MARK: Responder
extension StaticRoute {
    public func responder(
        middleware: some StaticMiddlewareStorageProtocol
    ) throws(HTTPMessageError) -> (any StaticRouteResponderProtocol)? {
        return try response(middleware: middleware).string(escapeLineBreak: true)
    }
}

// MARK: Convenience inits
extension StaticRoute {
    #if Inlinable
    @inlinable
    #endif
    public static func on(
        version: HTTPVersion = .v1_1,
        method: any HTTPRequestMethodProtocol,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: some ResponseBodyProtocol,
    ) -> Self {
        return Self(version: version, method: method, path: path, isCaseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func on(
        version: HTTPVersion = .v1_1,
        method: any HTTPRequestMethodProtocol,
        path: [String],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: (some HTTPMediaTypeProtocol)? = nil,
        charset: Charset? = nil,
        body: some ResponseBodyProtocol,
    ) -> Self {
        let mediaType:HTTPMediaType?
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
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: some ResponseBodyProtocol,
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
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: (some HTTPMediaTypeProtocol)? = nil,
        charset: Charset? = nil,
        body: some ResponseBodyProtocol,
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
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: some ResponseBodyProtocol,
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
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: some ResponseBodyProtocol,
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
        status: HTTPResponseStatus.Code = HTTPStandardResponseStatus.notImplemented.code,
        contentType: (some HTTPMediaTypeProtocol)? = nil,
        charset: Charset? = nil,
        body: some ResponseBodyProtocol,
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
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: some ResponseBodyProtocol,
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
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: some ResponseBodyProtocol,
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
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: some ResponseBodyProtocol,
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
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: some ResponseBodyProtocol,
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
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: some ResponseBodyProtocol,
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
        contentType: HTTPMediaType? = nil,
        charset: Charset? = nil,
        body: some ResponseBodyProtocol,
    ) -> Self {
        return on(version: version, method: HTTPStandardRequestMethod.patch, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, charset: charset, body: body)
    }
}