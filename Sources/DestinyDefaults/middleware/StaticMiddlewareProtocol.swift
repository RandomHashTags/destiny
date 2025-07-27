
import OrderedCollections
import DestinyBlueprint

/// Core Static Middleware protocol which handles static & dynamic routes at compile time.
public protocol StaticMiddlewareProtocol: MiddlewareProtocol {
    associatedtype ConcreteCookie:HTTPCookieProtocol

    @inlinable
    func handlesVersion(_ version: HTTPVersion) -> Bool

    @inlinable
    func handlesMethod(_ method: some HTTPRequestMethodProtocol) -> Bool

    @inlinable
    func handlesStatus(_ code: HTTPResponseStatus.Code) -> Bool

    @inlinable
    func handlesContentType(_ mediaType: HTTPMediaType?) -> Bool

    /// Response http version this middleware applies to routes.
    var appliesVersion: HTTPVersion? { get }

    /// Response status this middleware applies to routes.
    var appliesStatus: HTTPResponseStatus.Code? { get }

    /// Response content type this middleware applies to routes.
    var appliesContentType: HTTPMediaType? { get }
    
    /// Response headers this middleware applies to routes.
    var appliesHeaders: OrderedDictionary<String, String> { get }

    /// Response cookies this middleware applies to routes.
    var appliesCookies: [ConcreteCookie] { get }

    /// Whether or not this middleware handles a route with the given options.
    @inlinable
    func handles(
        version: HTTPVersion,
        path: String,
        method: some HTTPRequestMethodProtocol,
        contentType: HTTPMediaType?,
        status: HTTPResponseStatus.Code
    ) -> Bool

    /// Updates the given variables by applying this middleware.
    @inlinable
    func apply(
        version: inout HTTPVersion,
        contentType: inout HTTPMediaType?,
        status: inout HTTPResponseStatus.Code,
        headers: inout OrderedDictionary<String, String>,
        cookies: inout [any HTTPCookieProtocol]
    )
}
extension StaticMiddlewareProtocol {
    @inlinable
    public func apply(
        version: inout HTTPVersion,
        contentType: inout HTTPMediaType?,
        status: inout HTTPResponseStatus.Code,
        headers: inout OrderedDictionary<String, String>,
        cookies: inout [any HTTPCookieProtocol]
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

    @inlinable
    public func apply(
        contentType: inout HTTPMediaType?,
        to response: inout some DynamicResponseProtocol
    ) {
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
            response.appendCookie(cookie)
        }
        // TODO: fix
    }
}