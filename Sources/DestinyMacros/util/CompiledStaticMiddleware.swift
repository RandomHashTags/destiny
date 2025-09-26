
#if StaticMiddleware

import DestinyBlueprint
import DestinyDefaults

// MARK: CompiledStaticMiddleware
/// Default Static Middleware implementation which handles static & dynamic routes at compile time.
public final class CompiledStaticMiddleware: StaticMiddlewareProtocol, @unchecked Sendable {
    /// Route request versions this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all versions.
    public let handlesVersions:Set<HTTPVersion>?

    /// Route request methods this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all methods.
    public let handlesMethods:[HTTPRequestMethod]?

    /// Route response statuses this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all statuses.
    public let handlesStatuses:Set<HTTPResponseStatus.Code>?

    /// HTTP Content Types this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all content types.
    public let handlesContentTypes:Set<String>?

    public let appliesVersion:HTTPVersion?
    public let appliesStatus:HTTPResponseStatus.Code?
    public let appliesContentType:String?
    public let appliesHeaders:HTTPHeaders
    public let appliesCookies:[HTTPCookie]
    public let excludedRoutes:Set<String>

    public var appliedAtLeastOnce = false

    public init(
        handlesVersions: Set<HTTPVersion>? = nil,
        handlesMethods: [HTTPRequestMethod]? = nil,
        handlesStatuses: Set<HTTPResponseStatus.Code>? = nil,
        handlesContentTypes: Set<String>? = nil,
        appliesVersion: HTTPVersion? = nil,
        appliesStatus: HTTPResponseStatus.Code? = nil,
        appliesContentType: String? = nil,
        appliesHeaders: HTTPHeaders = .init(),
        appliesCookies: [HTTPCookie] = [],
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
}

// MARK: Handles
extension CompiledStaticMiddleware {
    #if Inlinable
    @inlinable
    #endif
    public func handles(
        version: HTTPVersion,
        path: String,
        method: some HTTPRequestMethodProtocol,
        contentType: String?,
        status: HTTPResponseStatus.Code
    ) -> Bool {
        return !excludedRoutes.contains(path)
            && handlesVersion(version)
            && handlesMethod(method)
            && handlesContentType(contentType)
            && handlesStatus(status)
    }

    #if Inlinable
    @inlinable
    #endif
    public func handlesVersion(_ version: HTTPVersion) -> Bool {
        handlesVersions?.contains(version) ?? true
    }

    #if Inlinable
    @inlinable
    #endif
    public func handlesMethod(_ method: some HTTPRequestMethodProtocol) -> Bool {
        guard let handlesMethods else { return true }
        let methodName = method.rawNameString()
        for m in handlesMethods {
            if m.rawNameString() == methodName {
                return true
            }
        }
        return false
    }

    #if Inlinable
    @inlinable
    #endif
    public func handlesStatus(_ code: HTTPResponseStatus.Code) -> Bool {
        handlesStatuses?.contains(code) ?? true
    }

    #if Inlinable
    @inlinable
    #endif
    public func handlesContentType(_ contentType: String?) -> Bool {
        guard let handlesContentTypes else { return true }
        if let contentType {
            return handlesContentTypes.contains(contentType)
        } else {
            return false
        }
    }
}

// MARK: Apply
extension CompiledStaticMiddleware {
    #if Inlinable
    @inlinable
    #endif
    public func apply(
        version: inout HTTPVersion,
        contentType: inout String?,
        status: inout HTTPResponseStatus.Code,
        headers: inout some HTTPHeadersProtocol,
        cookies: inout [HTTPCookie]
    ) {
        appliedAtLeastOnce = true
        if let appliesVersion {
            version = appliesVersion
        }
        if let appliesStatus {
            status = appliesStatus
        }
        if let appliesContentType {
            contentType = appliesContentType
        }
        for (header, value) in appliesHeaders {
            headers[header] = value
        }
        cookies.append(contentsOf: appliesCookies)
    }

    #if Inlinable
    @inlinable
    #endif
    public func apply(
        contentType: inout String?,
        to response: inout some DynamicResponseProtocol
    ) throws(AnyError) {
        appliedAtLeastOnce = true
        if let appliesVersion {
            response.setHTTPVersion(appliesVersion)
        }
        if let appliesStatus {
            response.setStatusCode(appliesStatus)
        }
        if let appliesContentType {
            contentType = appliesContentType
        }
        for (header, value) in appliesHeaders {
            response.setHeader(key: header, value: value)
        }
        for cookie in appliesCookies {
            do throws(HTTPCookieError) {
                try response.appendCookie(cookie)
            } catch {
                throw .httpCookieError(error)
            }
        }
    }
}

#endif