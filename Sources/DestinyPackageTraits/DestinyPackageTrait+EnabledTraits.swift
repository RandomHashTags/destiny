
extension DestinyPackageTrait {
    /// A set of other traits of this package that this trait enables.
    public var enabledTraits: Set<DestinyPackageTrait> {
        switch self {
        case .nonCopyable:
            [
                .nonCopyableHTTPServer,
                .nonCopyableResponders
            ]
        case .nonEmbedded:
            [
                .copyable,
                .routerSettings
            ]
        case .copyableMacroExpansionWithDateHeader,
                .copyableStaticStringWithDateHeader,
                .copyableStreamWithDateHeader:
            [.copyableDateHeaderPayload]
        case .copyableResponders:
            [
                .copyableInlineBytes,
                .copyableMacroExpansion,
                .copyableMacroExpansionWithDateHeader,
                .copyableString,
                .copyableStaticStringWithDateHeader,
                .copyableStringWithDateHeader,
                .copyableStreamWithDateHeader
            ]
        case .nonCopyableMacroExpansionWithDateHeader,
                .nonCopyableStaticStringWithDateHeader,
                .nonCopyableStreamWithDateHeader:
            [.nonCopyableDateHeaderPayload]
        case .nonCopyableResponders:
            [
                .nonCopyableBytes,
                .nonCopyableInlineBytes,
                .nonCopyableMacroExpansionWithDateHeader,
                .nonCopyableStaticStringWithDateHeader,
                .nonCopyableStreamWithDateHeader
            ]
        case .requestBody:
            [.requestHeaders]
        case .requestBodyStream:
            [.requestBody]
        case .routeGroup:
            [
                .dynamicResponderStorage,
                .staticResponderStorage
            ]
        case .unwrapArithmetic:
            [
                .unwrapAddition,
                .unwrapSubtraction
            ]
        default:
            []
        }
    }
}