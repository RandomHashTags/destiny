
#if MediaTypes

import DestinyBlueprint
import MediaTypes

extension Route {
    public init(
        head: HTTPResponseMessageHead = .default,
        method: some HTTPRequestMethodProtocol,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) {
        self.init(
            head: head,
            method: .init(method),
            path: path,
            isCaseSensitive: isCaseSensitive,
            contentType: mediaType?.template,
            body: body,
            handler: handler
        )
    }

    public init(
        head: HTTPResponseMessageHead = .default,
        method: HTTPRequestMethod,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        mediaType: (some MediaTypeProtocol)? = nil,
        body: (any ResponseBodyProtocol)? = nil,
        handler: (@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) async throws -> Void)? = nil
    ) {
        self.init(
            head: head,
            method: method,
            path: path,
            isCaseSensitive: isCaseSensitive,
            contentType: mediaType?.template,
            body: body,
            handler: handler
        )
    }
}

#endif