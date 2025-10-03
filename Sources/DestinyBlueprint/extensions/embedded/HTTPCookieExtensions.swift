
extension HTTPCookie: HTTPCookieProtocol {
    #if Inlinable
    @inlinable
    #endif
    public init(copying cookie: some HTTPCookieProtocol) throws(HTTPCookieError) {
        try self.init(
            name: cookie.name(),
            value: cookie.value(),
            maxAge: cookie.maxAge,
            expires: cookie.expiresString,
            domain: cookie.domain,
            path: cookie.path,
            isSecure: cookie.isSecure,
            isHTTPOnly: cookie.isHTTPOnly,
            sameSite: cookie.sameSite
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public init(unchecked cookie: some HTTPCookieProtocol) {
        self.init(
            name: cookie.name(),
            uncheckedValue: cookie.value(),
            maxAge: cookie.maxAge,
            expires: cookie.expiresString,
            domain: cookie.domain,
            path: cookie.path,
            isSecure: cookie.isSecure,
            isHTTPOnly: cookie.isHTTPOnly,
            sameSite: cookie.sameSite
        )
    }
}