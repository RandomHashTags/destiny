
#if StaticMiddleware

    import DestinyBlueprint
    import DestinyDefaults

    extension StaticMiddleware {
        public init(
            handlesVersions: Set<HTTPVersion>? = nil,
            handlesMethods: [any HTTPRequestMethodProtocol]? = nil,
            handlesStatuses: Set<HTTPResponseStatus.Code>? = nil,
            handlesContentTypes: [String]? = nil,
            appliesVersion: HTTPVersion? = nil,
            appliesStatus: HTTPResponseStatus.Code? = nil,
            appliesContentType: String? = nil,
            appliesHeaders: HTTPHeaders = .init(),
            appliesCookies: [HTTPCookie] = [],
            excludedRoutes: Set<String> = []
        ) {
            self.init(
                handlesVersions: handlesVersions,
                handlesMethods: handlesMethods?.map({ .init($0) }),
                handlesStatuses: handlesStatuses,
                handlesContentTypes: handlesContentTypes,
                appliesVersion: appliesVersion,
                appliesStatus: appliesStatus,
                appliesContentType: appliesContentType,
                appliesHeaders: appliesHeaders,
                appliesCookies: appliesCookies,
                excludedRoutes: excludedRoutes
            )
        }
    }

    #if MediaTypes

    import MediaTypes

    extension StaticMiddleware {
        public init(
            handlesVersions: Set<HTTPVersion>? = nil,
            handlesMethods: [any HTTPRequestMethodProtocol]? = nil,
            handlesStatuses: Set<HTTPResponseStatus.Code>? = nil,
            handlesMediaTypes: [any MediaTypeProtocol]? = nil,
            appliesVersion: HTTPVersion? = nil,
            appliesStatus: HTTPResponseStatus.Code? = nil,
            appliesMediaType: MediaType? = nil,
            appliesHeaders: HTTPHeaders = .init(),
            appliesCookies: [HTTPCookie] = [],
            excludedRoutes: Set<String> = []
        ) {
            self.init(
                handlesVersions: handlesVersions,
                handlesMethods: handlesMethods?.map({ .init($0) }),
                handlesStatuses: handlesStatuses,
                handlesContentTypes: handlesMediaTypes?.map({ $0.template }),
                appliesVersion: appliesVersion,
                appliesStatus: appliesStatus,
                appliesContentType: appliesMediaType?.template,
                appliesHeaders: appliesHeaders,
                appliesCookies: appliesCookies,
                excludedRoutes: excludedRoutes
            )
        }
    }
    #endif

#endif