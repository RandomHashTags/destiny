
#if Copyable && MediaTypes

import DestinyBlueprint
import MediaTypes

extension Route {
    public static func on(
        head: HTTPResponseMessageHead = .default,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return Self(
            head: head,
            method: .init(method),
            path: path,
            isCaseSensitive: isCaseSensitive,
            contentType: mediaType?.template,
            body: body,
            handler: handler
        )
    }

    public static func get(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return Self(
            head: head,
            method: HTTPRequestMethod(name: "GET"),
            path: path,
            isCaseSensitive: isCaseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    public static func head(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return Self(
            head: head,
            method: HTTPRequestMethod(name: "HEAD"),
            path: path,
            isCaseSensitive: isCaseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    public static func post(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return Self(
            method: HTTPRequestMethod(name: "POST"),
            path: path,
            isCaseSensitive: isCaseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    public static func put(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return Self(
            head: head,
            method: HTTPRequestMethod(name: "PUT"),
            path: path,
            isCaseSensitive: isCaseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    public static func delete(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return Self(
            head: head,
            method: HTTPRequestMethod(name: "DELETE"),
            path: path,
            isCaseSensitive: isCaseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    public static func connect(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return Self(
            head: head,
            method: HTTPRequestMethod(name: "CONNECT"),
            path: path,
            isCaseSensitive: isCaseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    public static func options(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return Self(
            head: head,
            method: HTTPRequestMethod(name: "OPTIONS"),
            path: path,
            isCaseSensitive: isCaseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    public static func trace(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return Self(
            head: head,
            method: HTTPRequestMethod(name: "TRACE"),
            path: path,
            isCaseSensitive: isCaseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }

    public static func patch(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        return Self(
            head: head,
            method: HTTPRequestMethod(name: "PATCH"),
            path: path,
            isCaseSensitive: isCaseSensitive,
            mediaType: mediaType,
            body: body,
            handler: handler
        )
    }
}

#endif