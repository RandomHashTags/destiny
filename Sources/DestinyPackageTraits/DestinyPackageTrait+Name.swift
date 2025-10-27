
extension DestinyPackageTrait {
    /// The trait's canonical name.
    public var name: String {
        switch self {
        case .cors: "CORS"
        case .httpCookie: "HTTPCookie"
        case .mutableRouter: "MutableRouter"
        case .percentEncoding: "PercentEncoding"
        case .protocols: "Protocols"
        case .rateLimits: "RateLimits"
        case .requestBody: "RequestBody"
        case .requestBodyStream: "RequestBodyStream"
        case .requestHeaders: "RequestHeaders"
        case .routeGroup: "RouteGroup"
        case .routePath: "RoutePath"
        case .routerSettings: "RouterSettings"
        case .staticMiddleware: "StaticMiddleware"
        case .staticRedirectionRoute: "StaticRedirectionRoute"

        case .dynamicResponderStorage: "DynamicResponderStorage"
        case .staticResponderStorage: "StaticResponderStorage"

        case .nonCopyableHTTPServer: "NonCopyableHTTPServer"

        case .copyableDateHeaderPayload: "CopyableDateHeaderPayload"
        case .copyableBytes: "CopyableBytes"
        case .copyableInlineBytes: "CopyableInlineBytes"
        case .copyableMacroExpansion: "CopyableMacroExpansion"
        case .copyableMacroExpansionWithDateHeader: "CopyableMacroExpansionWithDateHeader"
        case .copyableStaticStringWithDateHeader: "CopyableStaticStringWithDateHeader"
        case .copyableString: "CopyableString"
        case .copyableStringWithDateHeader: "CopyableStringWithDateHeader"
        case .copyableStreamWithDateHeader: "CopyableStreamWithDateHeader"
        case .copyableResponders: "CopyableResponders"

        case .nonCopyableDateHeaderPayload: "NonCopyableDateHeaderPayload"
        case .nonCopyableBytes: "NonCopyableBytes"
        case .nonCopyableInlineBytes: "NonCopyableInlineBytes"
        case .nonCopyableMacroExpansionWithDateHeader: "NonCopyableMacroExpansionWithDateHeader"
        case .nonCopyableStaticStringWithDateHeader: "NonCopyableStaticStringWithDateHeader"
        case .nonCopyableStreamWithDateHeader: "NonCopyableStreamWithDateHeader"
        case .nonCopyableResponders: "NonCopyableResponders"

        case .embedded: "EMBEDDED"
        case .nonEmbedded: "NonEmbedded"
        case .inlinable: "Inlinable"
        case .inlineAlways: "InlineAlways"

        case .copyable: "Copyable"
        case .nonCopyable: "NonCopyable"
        case .stringRequestMethod: "StringRequestMethod"

        case .epoll: "Epoll"
        case .liburing: "Liburing"
        case .logging: "Logging"
        case .mediaTypes: "MediaTypes"
        case .openAPI: "OpenAPI"
        case .unwrapAddition: "UnwrapAddition"
        case .unwrapSubtraction: "UnwrapSubtraction"
        case .unwrapArithmetic: "UnwrapArithmetic"
        }
    }
}