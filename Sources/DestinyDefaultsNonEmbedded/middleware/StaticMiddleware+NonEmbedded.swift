
#if StaticMiddleware

    import DestinyBlueprint
    import DestinyDefaults

    extension StaticMiddleware {
        #if HTTPCookie
        public convenience init(
            handlesVersions: Set<HTTPVersion>? = nil,
            handlesMethods: [any HTTPRequestMethodProtocol]? = nil,
            handlesStatuses: Set<HTTPResponseStatus.Code>? = nil,
            handlesContentTypes: Set<String>? = nil,
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
        #else
        public convenience init(
            handlesVersions: Set<HTTPVersion>? = nil,
            handlesMethods: [any HTTPRequestMethodProtocol]? = nil,
            handlesStatuses: Set<HTTPResponseStatus.Code>? = nil,
            handlesContentTypes: Set<String>? = nil,
            appliesVersion: HTTPVersion? = nil,
            appliesStatus: HTTPResponseStatus.Code? = nil,
            appliesContentType: String? = nil,
            appliesHeaders: HTTPHeaders = .init(),
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
                excludedRoutes: excludedRoutes
            )
        }
        #endif
    }

    #if MediaTypes

    import MediaTypes

    extension StaticMiddleware {
        #if HTTPCookie
        public convenience init(
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
            let handlesContentTypes:Set<String>?
            if let handlesMediaTypes {
                handlesContentTypes = Set(handlesMediaTypes.map({ $0.template }))
            } else {
                handlesContentTypes = nil
            }
            self.init(
                handlesVersions: handlesVersions,
                handlesMethods: handlesMethods?.map({ .init($0) }),
                handlesStatuses: handlesStatuses,
                handlesContentTypes: handlesContentTypes,
                appliesVersion: appliesVersion,
                appliesStatus: appliesStatus,
                appliesContentType: appliesMediaType?.template,
                appliesHeaders: appliesHeaders,
                appliesCookies: appliesCookies,
                excludedRoutes: excludedRoutes
            )
        }
        #else
        public convenience init(
            handlesVersions: Set<HTTPVersion>? = nil,
            handlesMethods: [any HTTPRequestMethodProtocol]? = nil,
            handlesStatuses: Set<HTTPResponseStatus.Code>? = nil,
            handlesMediaTypes: [any MediaTypeProtocol]? = nil,
            appliesVersion: HTTPVersion? = nil,
            appliesStatus: HTTPResponseStatus.Code? = nil,
            appliesMediaType: MediaType? = nil,
            appliesHeaders: HTTPHeaders = .init(),
            excludedRoutes: Set<String> = []
        ) {
            let handlesContentTypes:Set<String>?
            if let handlesMediaTypes {
                handlesContentTypes = Set(handlesMediaTypes.map({ $0.template }))
            } else {
                handlesContentTypes = nil
            }
            self.init(
                handlesVersions: handlesVersions,
                handlesMethods: handlesMethods?.map({ .init($0) }),
                handlesStatuses: handlesStatuses,
                handlesContentTypes: handlesContentTypes,
                appliesVersion: appliesVersion,
                appliesStatus: appliesStatus,
                appliesContentType: appliesMediaType?.template,
                appliesHeaders: appliesHeaders,
                excludedRoutes: excludedRoutes
            )
        }
        #endif
    }
    #endif

#endif