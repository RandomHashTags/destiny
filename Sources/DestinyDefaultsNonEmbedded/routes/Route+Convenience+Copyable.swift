
#if Copyable

import DestinyBlueprint

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
        contentType: String? = nil,
        charset: Charset? = nil,
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
            contentType: contentType,
            charset: charset,
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
        contentType: String? = nil,
        charset: Charset? = nil,
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
            contentType: contentType,
            charset: charset,
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
        contentType: String? = nil,
        charset: Charset? = nil,
        headers: HTTPHeaders = .init(),
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            version: version,
            method: "HEAD",
            path: path,
            caseSensitive: caseSensitive,
            status: status,
            contentType: contentType,
            charset: charset,
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
        contentType: String? = nil,
        charset: Charset? = nil,
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
            contentType: contentType,
            charset: charset,
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
        contentType: String? = nil,
        charset: Charset? = nil,
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
            contentType: contentType,
            charset: charset,
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
        contentType: String? = nil,
        charset: Charset? = nil,
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
            contentType: contentType,
            charset: charset,
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
        contentType: String? = nil,
        charset: Charset? = nil,
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
            contentType: contentType,
            charset: charset,
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
        contentType: String? = nil,
        charset: Charset? = nil,
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
            contentType: contentType,
            charset: charset,
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
        contentType: String? = nil,
        charset: Charset? = nil,
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
            contentType: contentType,
            charset: charset,
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
        contentType: String? = nil,
        charset: Charset? = nil,
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
            contentType: contentType,
            charset: charset,
            headers: headers,
            body: body,
            handler: handler
        )
    }
}

#endif