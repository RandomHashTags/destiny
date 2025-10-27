
public enum DestinyPackageTrait: Sendable {
    // MARK: Functionality
    case cors
    case httpCookie
    case mutableRouter
    case percentEncoding
    case protocols
    case rateLimits
    case requestBody
    case requestBodyStream
    case requestHeaders
    case routeGroup
    case routePath
    case routerSettings
    case staticMiddleware
    case staticRedirectionRoute

    // MARK: Mutable router
    case dynamicResponderStorage
    case staticResponderStorage

    // MARK: Server
    case nonCopyableHTTPServer

    // MARK: Responders
    case copyableDateHeaderPayload
    case copyableInlineBytes
    case copyableMacroExpansion
    case copyableMacroExpansionWithDateHeader
    case copyableStaticStringWithDateHeader
    case copyableString
    case copyableStringWithDateHeader
    case copyableStreamWithDateHeader
    case copyableResponders

    case nonCopyableDateHeaderPayload
    case nonCopyableBytes
    case nonCopyableInlineBytes
    case nonCopyableMacroExpansionWithDateHeader
    case nonCopyableStaticStringWithDateHeader
    case nonCopyableStreamWithDateHeader
    case nonCopyableResponders

    // MARK: Performance
    case embedded
    case nonEmbedded
    case inlinable
    case inlineAlways

    // MARK: Misc
    case copyable
    case nonCopyable
    case stringRequestMethod

    // MARK: Third-party
    case epoll
    case liburing
    case logging
    case mediaTypes
    case openAPI
    case unwrapAddition
    case unwrapSubtraction
    case unwrapArithmetic
}