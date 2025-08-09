
import DestinyBlueprint

public enum DynamicCORSLogic: Sendable {
    case allowCredentials_exposedHeaders_maxAge(allowedHeaders: String, allowedMethods: String, exposedHeaders: String, maxAge: String)
    case allowCredentials_exposedHeaders(allowedHeaders: String, allowedMethods: String, exposedHeaders: String)
    case allowCredentials_maxAge(allowedHeaders: String, allowedMethods: String, maxAge: String)
    case allowCredentials(allowedHeaders: String, allowedMethods: String)
    case exposedHeaders_maxAge(allowedHeaders: String, allowedMethods: String, exposedHeaders: String, maxAge: String)
    case exposedHeaders(allowedHeaders: String, allowedMethods: String, exposedHeaders: String)
    case maxAge(allowedHeaders: String, allowedMethods: String, maxAge: String)
    case minimum(allowedHeaders: String, allowedMethods: String)

    @inlinable
    public func apply(
        to response: inout some DynamicResponseProtocol
    ) {
        switch self {
        case .allowCredentials_exposedHeaders_maxAge(let allowedHeaders, let allowedMethods, let exposedHeaders, let maxAge):
            DynamicCORSMiddleware.logic_allowCredentials_exposedHeaders_maxAge(&response, allowedHeaders, allowedMethods, exposedHeaders, maxAge)
        case .allowCredentials_exposedHeaders(let allowedHeaders, let allowedMethods, let exposedHeaders):
            DynamicCORSMiddleware.logic_allowCredentials_exposedHeaders(&response, allowedHeaders, allowedMethods, exposedHeaders)
        case .allowCredentials_maxAge(let allowedHeaders, let allowedMethods, let maxAge):
            DynamicCORSMiddleware.logic_allowCredentials_maxAge(&response, allowedHeaders, allowedMethods, maxAge)
        case .allowCredentials(let allowedHeaders, let allowedMethods):
            DynamicCORSMiddleware.logic_allowCredentials(&response, allowedHeaders, allowedMethods)
        case .exposedHeaders_maxAge(let allowedHeaders, let allowedMethods, let exposedHeaders, let maxAge):
            DynamicCORSMiddleware.logic_exposedHeaders_maxAge(&response, allowedHeaders, allowedMethods, exposedHeaders, maxAge)
        case .exposedHeaders(let allowedHeaders, let allowedMethods, let exposedHeaders):
            DynamicCORSMiddleware.logic_exposedHeaders(&response, allowedHeaders, allowedMethods, exposedHeaders)
        case .maxAge(let allowedHeaders, let allowedMethods, let maxAge):
            DynamicCORSMiddleware.logic_maxAge(&response, allowedHeaders, allowedMethods, maxAge)
        case .minimum(let allowedHeaders, let allowedMethods):
            DynamicCORSMiddleware.handleSharedLogic(&response, allowedHeaders, allowedMethods)
        }
    }
}