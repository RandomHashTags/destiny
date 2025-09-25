
#if StaticMiddleware

import DestinyBlueprint

#if MediaTypes
import MediaTypes
#endif

// MARK: StaticMiddleware
/// Default Static Middleware implementation which handles static & dynamic routes at compile time.
public struct StaticMiddleware: StaticMiddlewareProtocol {
    /// HTTP Versions this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all versions.
    public let handlesVersions:Set<HTTPVersion>?

    /// HTTP Request Methods this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all methods.
    public let handlesMethods:[HTTPRequestMethod]?

    /// HTTP Response Status codes this middleware handles.
    /// 
    /// - Warning: `nil` makes it handle all status codes.
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
}

// MARK: Init
extension StaticMiddleware {
    public init(
        handlesVersions: Set<HTTPVersion>? = nil,
        handlesMethods: [HTTPRequestMethod]? = nil,
        handlesStatuses: Set<HTTPResponseStatus.Code>? = nil,
        handlesContentTypes: [String]? = nil,
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
        if let handlesContentTypes {
            self.handlesContentTypes = Set(handlesContentTypes)
        } else {
            self.handlesContentTypes = nil
        }
        self.appliesVersion = appliesVersion
        self.appliesStatus = appliesStatus
        self.appliesContentType = appliesContentType
        self.appliesHeaders = appliesHeaders
        self.appliesCookies = appliesCookies
        self.excludedRoutes = excludedRoutes
    }

    #if MediaTypes
        public init(
            handlesVersions: Set<HTTPVersion>? = nil,
            handlesMethods: [HTTPRequestMethod]? = nil,
            handlesStatuses: Set<HTTPResponseStatus.Code>? = nil,
            handlesMediaTypes: [MediaType]? = nil,
            appliesVersion: HTTPVersion? = nil,
            appliesStatus: HTTPResponseStatus.Code? = nil,
            appliesMediaType: MediaType? = nil,
            appliesHeaders: HTTPHeaders = .init(),
            appliesCookies: [HTTPCookie] = [],
            excludedRoutes: Set<String> = []
        ) {
            self.handlesVersions = handlesVersions
            self.handlesMethods = handlesMethods
            self.handlesStatuses = handlesStatuses
            if let handlesMediaTypes {
                self.handlesContentTypes = Set(handlesMediaTypes.map({ $0.template }))
            } else {
                self.handlesContentTypes = nil
            }
            self.appliesVersion = appliesVersion
            self.appliesStatus = appliesStatus
            self.appliesContentType = appliesMediaType?.template
            self.appliesHeaders = appliesHeaders
            self.appliesCookies = appliesCookies
            self.excludedRoutes = excludedRoutes
        }
    #endif
}

// MARK: Handles
extension StaticMiddleware {
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
        if let contentType {
            handlesContentTypes?.contains(contentType) ?? true
        } else {
            true
        }
    }
}

// MARK: Apply
extension StaticMiddleware {
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