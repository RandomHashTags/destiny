
#if StaticMiddleware

import DestinyBlueprint
import DestinyDefaults

// MARK: Init
extension StaticMiddleware {
    public init(
        handlesVersions: Set<HTTPVersion>? = nil,
        handlesMethods: [any HTTPRequestMethodProtocol]? = nil,
        handlesStatuses: Set<HTTPResponseStatus.Code>? = nil,
        handlesContentTypes: [any HTTPMediaTypeProtocol]? = nil,
        appliesVersion: HTTPVersion? = nil,
        appliesStatus: HTTPResponseStatus.Code? = nil,
        appliesContentType: HTTPMediaType? = nil,
        appliesHeaders: HTTPHeaders = .init(),
        appliesCookies: [HTTPCookie] = [],
        excludedRoutes: Set<String> = []
    ) {
        self.init(
            handlesVersions: handlesVersions,
            handlesMethods: handlesMethods?.map({ .init($0) }),
            handlesStatuses: handlesStatuses,
            handlesContentTypes: handlesContentTypes?.map({ .init($0) }),
            appliesVersion: appliesVersion,
            appliesStatus: appliesStatus,
            appliesContentType: appliesContentType,
            appliesHeaders: appliesHeaders,
            appliesCookies: appliesCookies,
            excludedRoutes: excludedRoutes
        )
    }
}

#endif