
extension DestinyPackageTrait {
    public var isExplicitlyEnabledByDefault: Bool {
        switch self {
        case .cors,
                .httpCookie,
                .nonCopyable,
                .nonEmbedded,
                .percentEncoding,
                .protocols,
                .requestBody,
                .requestBodyStream,
                .requestHeaders,
                .routeGroup,
                .staticMiddleware,
                .staticRedirectionRoute,

                .inlinable,

                .copyableResponders,
                .nonCopyableResponders,

                .stringRequestMethod,

                .logging,
                .mediaTypes,
                .openAPI,
                .unwrapArithmetic:
            true
        case .inlineAlways:
            false // disabled by default because it is shown to hurt performance
        case .rateLimits:
            false // not yet implemented
        case .routePath:
            false // not yet integrated
        case .mutableRouter:
            false // disabled by default since no other Swift networking library allows that functionality
        default:
            false
        }
    }
}