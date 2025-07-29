
/// Core Static Middleware protocol which handles static & dynamic routes at compile time.
public protocol StaticMiddlewareProtocol: MiddlewareProtocol {
    func handlesVersion(_ version: HTTPVersion) -> Bool

    func handlesMethod(_ method: some HTTPRequestMethodProtocol) -> Bool

    func handlesStatus(_ code: HTTPResponseStatus.Code) -> Bool

    func handlesContentType(_ mediaType: HTTPMediaType?) -> Bool

    /// Whether or not this middleware handles a route with the given options.
    func handles(
        version: HTTPVersion,
        path: String,
        method: some HTTPRequestMethodProtocol,
        contentType: HTTPMediaType?,
        status: HTTPResponseStatus.Code
    ) -> Bool

    /// Updates the given variables by applying this middleware.
    func apply(
        version: inout HTTPVersion,
        contentType: inout HTTPMediaType?,
        status: inout HTTPResponseStatus.Code,
        headers: inout some HTTPHeadersProtocol,
        cookies: inout [any HTTPCookieProtocol]
    )

    /// Updates the `response` by applying this middleware.
    func apply(
        contentType: inout HTTPMediaType?,
        to response: inout some DynamicResponseProtocol
    )
}