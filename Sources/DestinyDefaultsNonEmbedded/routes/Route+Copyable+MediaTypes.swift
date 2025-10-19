
#if Copyable && MediaTypes

import DestinyBlueprint
import MediaTypes

extension Route {
    #if Inlinable
    @inlinable
    #endif
    public static func on(
        head: HTTPResponseMessageHead = .default,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        caseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return Self(
            head: head,
            method: .init(method),
            path: path,
            isCaseSensitive: caseSensitive,
            contentType: mediaType?.template,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func get(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        caseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            head: head,
            method: HTTPRequestMethod(name: "GET"),
            path: path,
            caseSensitive: caseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func head(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        caseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            head: head,
            method: HTTPRequestMethod(name: "HEAD"),
            path: path,
            caseSensitive: caseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func post(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        caseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            method: HTTPRequestMethod(name: "POST"),
            path: path,
            caseSensitive: caseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func put(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        caseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            head: head,
            method: HTTPRequestMethod(name: "PUT"),
            path: path,
            caseSensitive: caseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func delete(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        caseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            head: head,
            method: HTTPRequestMethod(name: "DELETE"),
            path: path,
            caseSensitive: caseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func connect(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        caseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            head: head,
            method: HTTPRequestMethod(name: "CONNECT"),
            path: path,
            caseSensitive: caseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func options(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        caseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            head: head,
            method: HTTPRequestMethod(name: "OPTIONS"),
            path: path,
            caseSensitive: caseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func trace(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        caseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            head: head,
            method: HTTPRequestMethod(name: "TRACE"),
            path: path,
            caseSensitive: caseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public static func patch(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        caseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout any HTTPRequestProtocol & ~Copyable, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return on(
            head: head,
            method: HTTPRequestMethod(name: "PATCH"),
            path: path,
            caseSensitive: caseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }
}

#endif