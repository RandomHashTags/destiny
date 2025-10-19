
#if MediaTypes

import DestinyBlueprint
import DestinyDefaults
import MediaTypes

// MARK: HTTPCookie
extension Route {
    #if HTTPCookie
        public init(
            version: HTTPVersion = .v1_1,
            method: some HTTPRequestMethodProtocol,
            path: [PathComponent],
            isCaseSensitive: Bool = true,
            status: HTTPResponseStatus.Code = 501, // not implemented
            mediaType: (some MediaTypeProtocol)? = nil,
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
            mediaType: (some MediaTypeProtocol)? = nil,
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
}

#if Copyable
// MARK: Copyable

extension Route { // TODO: fix (missing support for cookies)
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
        return Self(
            version: version,
            method: method,
            path: path,
            isCaseSensitive: caseSensitive,
            status: status,
            contentType: mediaType?.template,
            headers: headers,
            body: body,
            handler: handler
        )
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
        return on(
            version: version,
            method: HTTPRequestMethod(name: "GET"),
            path: path,
            caseSensitive: caseSensitive,
            status: status,
            mediaType: mediaType,
            headers: headers,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func head(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: (some MediaTypeProtocol)? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            version: version,
            method: HTTPRequestMethod(name: "HEAD"),
            path: path,
            caseSensitive: caseSensitive,
            status: status,
            mediaType: mediaType,
            headers: headers,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func post(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: (some MediaTypeProtocol)? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            version: version,
            method: HTTPRequestMethod(name: "POST"),
            path: path,
            caseSensitive: caseSensitive,
            status: status,
            mediaType: mediaType,
            headers: headers,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func put(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: (some MediaTypeProtocol)? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            version: version,
            method: HTTPRequestMethod(name: "PUT"),
            path: path,
            caseSensitive: caseSensitive,
            status: status,
            mediaType: mediaType,
            headers: headers,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func delete(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: (some MediaTypeProtocol)? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            version: version,
            method: HTTPRequestMethod(name: "DELETE"),
            path: path,
            caseSensitive: caseSensitive,
            status: status,
            mediaType: mediaType,
            headers: headers,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func connect(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: (some MediaTypeProtocol)? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            version: version,
            method: HTTPRequestMethod(name: "CONNECT"),
            path: path,
            caseSensitive: caseSensitive,
            status: status,
            mediaType: mediaType,
            headers: headers,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func options(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: (some MediaTypeProtocol)? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            version: version,
            method: HTTPRequestMethod(name: "OPTIONS"),
            path: path,
            caseSensitive: caseSensitive,
            status: status,
            mediaType: mediaType,
            headers: headers,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func trace(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: (some MediaTypeProtocol)? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            version: version,
            method: HTTPRequestMethod(name: "TRACE"),
            path: path,
            caseSensitive: caseSensitive,
            status: status,
            mediaType: mediaType,
            headers: headers,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func patch(
        version: HTTPVersion = .v1_1,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        mediaType: (some MediaTypeProtocol)? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            version: version,
            method: HTTPRequestMethod(name: "PATCH"),
            path: path,
            caseSensitive: caseSensitive,
            status: status,
            mediaType: mediaType,
            headers: headers,
            body: body,
            handler: handler
        )
    }
}

#endif

#endif