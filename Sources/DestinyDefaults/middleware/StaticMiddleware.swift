
import DestinyBlueprint
import OrderedCollections

// MARK: StaticMiddleware
/// Default Static Middleware implementation which handles static & dynamic routes at compile time.
public struct StaticMiddleware: StaticMiddlewareProtocol {
    public typealias Cookie = HTTPCookie

    /// Route request versions this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all versions.
    public let handlesVersions:Set<HTTPVersion>?

    /// Route request methods this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all methods.
    public let handlesMethods:[any HTTPRequestMethodProtocol]?

    /// Route response statuses this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all statuses.
    public let handlesStatuses:Set<HTTPResponseStatus.Code>?

    /// The route content types this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all content types.
    public let handlesContentTypes:Set<HTTPMediaType>?

    public let appliesVersion:HTTPVersion?
    public let appliesStatus:HTTPResponseStatus.Code?
    public let appliesContentType:HTTPMediaType?
    public let appliesHeaders:OrderedDictionary<String, String>
    public let appliesCookies:[Cookie]
    public let excludedRoutes:Set<String>

    public init(
        handlesVersions: Set<HTTPVersion>? = nil,
        handlesMethods: [any HTTPRequestMethodProtocol]? = nil,
        handlesStatuses: Set<HTTPResponseStatus.Code>? = nil,
        handlesContentTypes: Set<HTTPMediaType>? = nil,
        appliesVersion: HTTPVersion? = nil,
        appliesStatus: HTTPResponseStatus.Code? = nil,
        appliesContentType: HTTPMediaType? = nil,
        appliesHeaders: OrderedDictionary<String, String> = [:],
        appliesCookies: [Cookie] = [],
        excludedRoutes: Set<String> = []
    ) {
        self.handlesVersions = handlesVersions
        self.handlesMethods = handlesMethods
        self.handlesStatuses = handlesStatuses
        self.handlesContentTypes = handlesContentTypes
        self.appliesVersion = appliesVersion
        self.appliesStatus = appliesStatus
        self.appliesContentType = appliesContentType
        self.appliesHeaders = appliesHeaders
        self.appliesCookies = appliesCookies
        self.excludedRoutes = excludedRoutes
    }

    @inlinable
    public func handles(
        version: HTTPVersion,
        path: String,
        method: some HTTPRequestMethodProtocol,
        contentType: HTTPMediaType?,
        status: HTTPResponseStatus.Code
    ) -> Bool {
        return !excludedRoutes.contains(path)
            && handlesVersion(version)
            && handlesMethod(method)
            && handlesContentType(contentType)
            && handlesStatus(status)
    }
}

extension StaticMiddleware {
    @inlinable
    public func handlesVersion(_ version: HTTPVersion) -> Bool {
        handlesVersions?.contains(version) ?? true
    }

    @inlinable
    public func handlesMethod(_ method: some HTTPRequestMethodProtocol) -> Bool {
        guard let handlesMethods else { return true }
        let rn = method.rawNameString()
        for m in handlesMethods {
            if m.rawNameString() == rn {
                return true
            }
        }
        return false
    }

    @inlinable
    public func handlesStatus(_ code: HTTPResponseStatus.Code) -> Bool {
        handlesStatuses?.contains(code) ?? true
    }

    @inlinable
    public func handlesContentType(_ mediaType: HTTPMediaType?) -> Bool {
        if let mediaType {
            handlesContentTypes?.contains(mediaType) ?? true
        } else {
            true
        }
    }
}