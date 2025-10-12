
extension HTTPCookie {
    #if Inlinable
    @inlinable
    #endif
    public init(unchecked cookie: HTTPCookie) {
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