
extension DestinyPackageTrait {
    /// Returns: Whether or not the trait is currently enabled.
    public var isEnabled: Bool {
        switch self {
        // MARK: Functionality
        case .cors:
            #if CORS
            true
            #else
            false
            #endif
        case .httpCookie:
            #if HTTPCookie
            true
            #else
            false
            #endif
        case .mutableRouter:
            #if MutableRouter
            true
            #else
            false
            #endif
        case .percentEncoding:
            #if PercentEncoding
            true
            #else
            false
            #endif
        case .protocols:
            #if Protocols
            true
            #else
            false
            #endif
        case .rateLimits:
            #if RateLimits
            true
            #else
            false
            #endif
        case .requestBody:
            #if RequestBody
            true
            #else
            false
            #endif
        case .requestBodyStream:
            #if RequestBodyStream
            true
            #else
            false
            #endif
        case .requestHeaders:
            #if RequestHeaders
            true
            #else
            false
            #endif
        case .routeGroup:
            #if RouteGroup
            true
            #else
            false
            #endif
        case .routePath:
            #if RoutePath
            true
            #else
            false
            #endif
        case .routerSettings:
            #if RouterSettings
            true
            #else
            false
            #endif
        case .staticMiddleware:
            #if StaticMiddleware
            true
            #else
            false
            #endif
        case .staticRedirectionRoute:
            #if StaticRedirectionRoute
            true
            #else
            false
            #endif

        // MARK: Mutable Router
        case .dynamicResponderStorage:
            #if DynamicResponderStorage
            true
            #else
            false
            #endif
        case .staticResponderStorage:
            #if StaticResponderStorage
            true
            #else
            false
            #endif

        // MARK: Server
        case .nonCopyableHTTPServer:
            #if NonCopyableHTTPServer
            true
            #else
            false
            #endif

        // MARK: Responders
        case .copyableDateHeaderPayload:
            #if CopyableDateHeaderPayload
            true
            #else
            false
            #endif
        case .copyableInlineBytes:
            #if CopyableInlineBytes
            true
            #else
            false
            #endif
        case .copyableMacroExpansion:
            #if CopyableMacroExpansion
            true
            #else
            false
            #endif
        case .copyableMacroExpansionWithDateHeader:
            #if CopyableMacroExpansionWithDateHeader
            true
            #else
            false
            #endif
        case .copyableStaticStringWithDateHeader:
            #if CopyableStaticStringWithDateHeader
            true
            #else
            false
            #endif
        case .copyableString:
            #if StringRouteResponder
            true
            #else
            false
            #endif
        case .copyableStringWithDateHeader:
            #if CopyableStringWithDateHeader
            true
            #else
            false
            #endif
        case .copyableStreamWithDateHeader:
            #if CopyableStreamWithDateHeader
            true
            #else
            false
            #endif
        case .copyableResponders:
            #if CopyableResponders
            true
            #else
            false
            #endif

        case .nonCopyableDateHeaderPayload:
            #if NonCopyableDateHeaderPayload
            true
            #else
            false
            #endif
        case .nonCopyableBytes:
            #if NonCopyableBytes
            true
            #else
            false
            #endif
        case .nonCopyableInlineBytes:
            #if NonCopyableInlineBytes
            true
            #else
            false
            #endif
        case .nonCopyableMacroExpansionWithDateHeader:
            #if NonCopyableMacroExpansionWithDateHeader
            true
            #else
            false
            #endif
        case .nonCopyableStaticStringWithDateHeader:
            #if NonCopyableStaticStringWithDateHeader
            true
            #else
            false
            #endif
        case .nonCopyableStreamWithDateHeader:
            #if NonCopyableStreamWithDateHeader
            true
            #else
            false
            #endif
        case .nonCopyableResponders:
            #if NonCopyableResponders
            true
            #else
            false
            #endif

        // MARK: Performance
        case .embedded:
            #if EMBEDDED
            true
            #else
            false
            #endif
        case .nonEmbedded:
            #if NonEmbedded
            true
            #else
            false
            #endif
        case .inlinable:
            #if Inlinable
            true
            #else
            false
            #endif
        case .inlineAlways:
            #if InlineAlways
            true
            #else
            false
            #endif

        // MARK: Misc
        case .copyable:
            #if Copyable
            true
            #else
            false
            #endif
        case .nonCopyable:
            #if NonCopyable
            true
            #else
            false
            #endif
        case .stringRequestMethod:
            #if StringRequestMethod
            true
            #else
            false
            #endif

        case .epoll:
            #if Epoll
            true
            #else
            false
            #endif
        case .liburing:
            #if Liburing
            true
            #else
            false
            #endif
        case .logging:
            #if Logging
            true
            #else
            false
            #endif
        case .mediaTypes:
            #if MediaTypes
            true
            #else
            false
            #endif
        case .openAPI:
            #if OpenAPI
            true
            #else
            false
            #endif
        case .unwrapAddition:
            #if UnwrapAddition
            true
            #else
            false
            #endif
        case .unwrapSubtraction:
            #if UnwrapSubtraction
            true
            #else
            false
            #endif
        case .unwrapArithmetic:
            #if UnwrapArithmetic
            true
            #else
            false
            #endif
        }
    }
}