
#if NonCopyable

import DestinyBlueprint
import DestinyDefaults

// TODO: fix (missing support for cookies)

extension Route {
    static func unsupportedNonCopyable() -> Self {
        fatalError("unsupported; only here to allow noncopyable response bodies to be available from the macros")
    }

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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
    }
}

#if MediaTypes

// MARK: MediaTypes
import MediaTypes

extension Route {
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
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
        unsupportedNonCopyable()
    }
}

#endif

#endif