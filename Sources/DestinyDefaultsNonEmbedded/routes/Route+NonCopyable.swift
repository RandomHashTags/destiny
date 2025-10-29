
#if NonCopyable

import DestinyBlueprint

extension Route {
    static func unsupportedNonCopyable() -> Self {
        fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
    }

    public static func on(
        head: HTTPResponseMessageHead = .default,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        unsupportedNonCopyable()
    }

    public static func get(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        unsupportedNonCopyable()
    }

    public static func head(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        unsupportedNonCopyable()
    }

    public static func post(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        unsupportedNonCopyable()
    }

    public static func put(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        unsupportedNonCopyable()
    }

    public static func delete(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        unsupportedNonCopyable()
    }

    public static func connect(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        unsupportedNonCopyable()
    }

    public static func options(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        unsupportedNonCopyable()
    }

    public static func trace(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        unsupportedNonCopyable()
    }

    public static func patch(
        head: HTTPResponseMessageHead = .default,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: consuming some ResponseBodyProtocol & ~Copyable,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) -> Self {
        unsupportedNonCopyable()
    }
}

#endif