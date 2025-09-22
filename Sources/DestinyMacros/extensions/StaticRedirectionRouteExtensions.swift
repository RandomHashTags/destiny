
import DestinyBlueprint
import DestinyDefaults

#if GenericHTTPMessage

extension StaticRedirectionRoute {
    /// The HTTP Message of this route. Computed at compile time.
    public func genericResponse() -> GenericHTTPResponseMessage<StaticString, HTTPCookie> {
        var headers = HTTPHeaders()
        headers["Date"] = HTTPDateFormat.placeholder
        return .redirect(to: to.joined(separator: "/"), version: version, status: status, headers: &headers)
    }
}

#endif

#if NonEmbedded

import DestinyDefaultsNonEmbedded

extension StaticRedirectionRoute {
    /// The HTTP Message of this route. Computed at compile time.
    public func nonEmbeddedResponse() -> HTTPResponseMessage {
        var headers = HTTPHeaders()
        headers["Date"] = HTTPDateFormat.placeholder
        return .redirect(to: to.joined(separator: "/"), version: version, status: status, headers: &headers)
    }
}
#endif