
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

    #if HTTPCookie
    /// Updates the given variables by applying this middleware.
    func apply(
        version: inout HTTPVersion,
        contentType: inout String?,
        status: inout HTTPResponseStatus.Code,
        headers: inout HTTPHeaders,
        cookies: inout [HTTPCookie]
    )
    #else
    /// Updates the given variables by applying this middleware.
    func apply(
        version: inout HTTPVersion,
        contentType: inout String?,
        status: inout HTTPResponseStatus.Code,
        headers: inout HTTPHeaders
    )
    #endif

    /// Updates the `response` by applying this middleware.
    /// 
    /// - Throws: `AnyError`
    func apply(
        contentType: inout String?,
        to response: inout some DynamicResponseProtocol
    ) throws(AnyError)
}

#endif