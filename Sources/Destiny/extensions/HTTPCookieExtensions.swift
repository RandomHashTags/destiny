
#if HTTPCookie

extension HTTPCookie {
    public init(unchecked cookie: HTTPCookie) {
        self.init(
            name: cookie._name,
            uncheckedValue: cookie._value,
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

#endif