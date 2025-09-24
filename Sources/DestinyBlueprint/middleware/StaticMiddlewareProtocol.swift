
#if StaticMiddleware

/// Core protocol that handles static and dynamic routes at compile time.
public protocol StaticMiddlewareProtocol: MiddlewareProtocol, ~Copyable {
    /// - Returns: Whether or not this middleware handles a route with the given options.
    func handles(
        version: HTTPVersion,
        path: String,
        method: some HTTPRequestMethodProtocol,
        contentType: String?,
        status: HTTPResponseStatus.Code
    ) -> Bool

    /// Updates the given variables by applying this middleware.
    func apply(
        version: inout HTTPVersion,
        contentType: inout String?,
        status: inout HTTPResponseStatus.Code,
        headers: inout some HTTPHeadersProtocol,
        cookies: inout [HTTPCookie]
    )

    /// Updates the `response` by applying this middleware.
    func apply(
        contentType: inout String?,
        to response: inout some DynamicResponseProtocol
    ) throws(AnyError)
}

#endif