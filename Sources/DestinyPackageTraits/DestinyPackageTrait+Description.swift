
extension DestinyPackageTrait {
    /// The trait's description.
    public var description: String? {
        switch self {
        case .cors: "Enables cross-origin resource sharing functionality."
        case .httpCookie: "Enables the default HTTPCookie implementation."
        case .mutableRouter: "Enables functionality that registers data to a Router at runtime."
        case .percentEncoding: "Enables percent encoding functionality."
        case .protocols: "Enables the design protocols and the DestinyBlueprint target."
        case .rateLimits: "Enables default rate limiting functionality."
        case .requestBody: "Enables functionality to access a request's body."
        case .requestBodyStream: "Enables functionality to stream a request's body."
        case .requestHeaders: "Enables functionality to access a request's headers."
        case .routeGroup: "Enables functionality to group routes together with shared endpoints and middleware."
        case .routePath: nil
        case .routerSettings: "Allows configuring the expanded router from the macros."
        case .staticMiddleware: "Enables static middleware functionality (should only be used in the macros)."
        case .staticRedirectionRoute: nil

        case .dynamicResponderStorage: "Enables a responder storage that can register dynamic data to a router at runtime."
        case .staticResponderStorage: "Enables a responder storage that can register static data to a router at runtime."

        case .nonCopyableHTTPServer: nil

        case .copyableDateHeaderPayload: nil
        case .copyableBytes: "Enables the copyable Bytes route responder."
        case .copyableInlineBytes: "Enables the copyable InlineBytes route responder."
        case .copyableMacroExpansion: "Enables the copyable MacroExpansion route responder."
        case .copyableMacroExpansionWithDateHeader: "Enables the copyable MacroExpansionWithDateHeader route responder."
        case .copyableStaticStringWithDateHeader: nil
        case .copyableString: "Makes `String` conform to route responder protocols for convenience."
        case .copyableStringWithDateHeader: nil
        case .copyableStreamWithDateHeader: nil
        case .copyableResponders: "Enables all copyable route responders."

        case .nonCopyableDateHeaderPayload: nil
        case .nonCopyableBytes: nil
        case .nonCopyableInlineBytes: nil
        case .nonCopyableMacroExpansionWithDateHeader: nil
        case .nonCopyableStaticStringWithDateHeader: nil
        case .nonCopyableStreamWithDateHeader: nil
        case .nonCopyableResponders: nil

        case .embedded: "Enables conditional compliation suitable for embedded mode."
        case .nonEmbedded: "Enables functionality suitable for non-embedded devices (mainly existentials)."
        case .inlinable: "Enables the `@inlinable` annotation where annotated."
        case .inlineAlways: "Enables the `@inline(__always)` annotation where annotated."

        case .copyable: "Enables all copyable package traits."
        case .nonCopyable: "Enables all noncopyable package traits."
        case .stringRequestMethod: "Makes `String` conform to `HTTPRequestMethodProtocol` for convenience."

        case .epoll: "Enables Epoll functionality (Linux only)."
        case .liburing: "Enables Liburing functionality (Linux only)."
        case .logging: "Enables swift-log functionality."
        case .mediaTypes: "Enables swift-media-types functionality."
        case .openAPI: "Enables functionality to support OpenAPI."
        case .unwrapAddition: "Enables unchecked overflow addition operators (`+!` and `+=!`)."
        case .unwrapSubtraction: "Enables unchecked overflow subtraction operators (`-!` and `-=!`)."
        case .unwrapArithmetic: "Enables unchecked overflow operators."
        }
    }
}