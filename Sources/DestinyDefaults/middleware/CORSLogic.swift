
#if CORS

/// List of all available CORS logic cases.
public enum CORSLogic: Sendable {
    case allowCredentials_exposedHeaders_maxAge(allowedHeaders: String, allowedMethods: String, exposedHeaders: String, maxAge: String)
    case allowCredentials_exposedHeaders(allowedHeaders: String, allowedMethods: String, exposedHeaders: String)
    case allowCredentials_maxAge(allowedHeaders: String, allowedMethods: String, maxAge: String)
    case allowCredentials(allowedHeaders: String, allowedMethods: String)
    case exposedHeaders_maxAge(allowedHeaders: String, allowedMethods: String, exposedHeaders: String, maxAge: String)
    case exposedHeaders(allowedHeaders: String, allowedMethods: String, exposedHeaders: String)
    case maxAge(allowedHeaders: String, allowedMethods: String, maxAge: String)
    case minimum(allowedHeaders: String, allowedMethods: String)
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Apply to response
extension CORSLogic {
    /// Applies CORS headers to a dynamic response.
    public func apply(
        to response: inout some DynamicResponseProtocol
    ) {
        switch self {
        case .allowCredentials_exposedHeaders_maxAge(let allowedHeaders, let allowedMethods, let exposedHeaders, let maxAge):
            CORSMiddleware.logic_allowCredentials_exposedHeaders_maxAge(&response, allowedHeaders, allowedMethods, exposedHeaders, maxAge)
        case .allowCredentials_exposedHeaders(let allowedHeaders, let allowedMethods, let exposedHeaders):
            CORSMiddleware.logic_allowCredentials_exposedHeaders(&response, allowedHeaders, allowedMethods, exposedHeaders)
        case .allowCredentials_maxAge(let allowedHeaders, let allowedMethods, let maxAge):
            CORSMiddleware.logic_allowCredentials_maxAge(&response, allowedHeaders, allowedMethods, maxAge)
        case .allowCredentials(let allowedHeaders, let allowedMethods):
            CORSMiddleware.logic_allowCredentials(&response, allowedHeaders, allowedMethods)
        case .exposedHeaders_maxAge(let allowedHeaders, let allowedMethods, let exposedHeaders, let maxAge):
            CORSMiddleware.logic_exposedHeaders_maxAge(&response, allowedHeaders, allowedMethods, exposedHeaders, maxAge)
        case .exposedHeaders(let allowedHeaders, let allowedMethods, let exposedHeaders):
            CORSMiddleware.logic_exposedHeaders(&response, allowedHeaders, allowedMethods, exposedHeaders)
        case .maxAge(let allowedHeaders, let allowedMethods, let maxAge):
            CORSMiddleware.logic_maxAge(&response, allowedHeaders, allowedMethods, maxAge)
        case .minimum(let allowedHeaders, let allowedMethods):
            CORSMiddleware.handleSharedLogic(&response, allowedHeaders, allowedMethods)
        }
    }
}

// MARK: Apply to headers
extension CORSLogic {
    /// Applies CORS headers to a `HTTPHeaders`.
    public func apply(
        to headers: inout HTTPHeaders
    ) {
        switch self {
        case .allowCredentials_exposedHeaders_maxAge(let allowedHeaders, let allowedMethods, let exposedHeaders, let maxAge):
            CORSMiddleware.logic_allowCredentials_exposedHeaders_maxAge(&headers, allowedHeaders, allowedMethods, exposedHeaders, maxAge)
        case .allowCredentials_exposedHeaders(let allowedHeaders, let allowedMethods, let exposedHeaders):
            CORSMiddleware.logic_allowCredentials_exposedHeaders(&headers, allowedHeaders, allowedMethods, exposedHeaders)
        case .allowCredentials_maxAge(let allowedHeaders, let allowedMethods, let maxAge):
            CORSMiddleware.logic_allowCredentials_maxAge(&headers, allowedHeaders, allowedMethods, maxAge)
        case .allowCredentials(let allowedHeaders, let allowedMethods):
            CORSMiddleware.logic_allowCredentials(&headers, allowedHeaders, allowedMethods)
        case .exposedHeaders_maxAge(let allowedHeaders, let allowedMethods, let exposedHeaders, let maxAge):
            CORSMiddleware.logic_exposedHeaders_maxAge(&headers, allowedHeaders, allowedMethods, exposedHeaders, maxAge)
        case .exposedHeaders(let allowedHeaders, let allowedMethods, let exposedHeaders):
            CORSMiddleware.logic_exposedHeaders(&headers, allowedHeaders, allowedMethods, exposedHeaders)
        case .maxAge(let allowedHeaders, let allowedMethods, let maxAge):
            CORSMiddleware.logic_maxAge(&headers, allowedHeaders, allowedMethods, maxAge)
        case .minimum(let allowedHeaders, let allowedMethods):
            CORSMiddleware.handleSharedLogic(&headers, allowedHeaders, allowedMethods)
        }
    }
}

#endif

#endif