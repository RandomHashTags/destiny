
import DestinyDefaults
import Foundation

extension HTTPCookie {
    public init(
        name: CookieName,
        value: CookieValue,
        maxAge: UInt64 = 0,
        expires: Date? = nil,
        domain: String? = nil,
        path: String? = nil,
        isSecure: Bool = false,
        isHTTPOnly: Bool = false,
        sameSite: HTTPCookieFlag.SameSite? = nil
    ) {
        let expiresString:String?
        if let expires {
            expiresString = "\(expires)"
        } else {
            expiresString = nil
        }
        self.init(
            name: name,
            value: value,
            maxAge: maxAge,
            expires: expiresString,
            domain: domain,
            path: path,
            isSecure: isSecure,
            isHTTPOnly: isHTTPOnly,
            sameSite: sameSite
        )
    }

    @inlinable
    public var expires: Date? {
        guard let expiresString else { return nil }
        return DateFormatter().date(from: expiresString)
    }
}