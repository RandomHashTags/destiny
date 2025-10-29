
#if StaticRedirectionRoute

import DestinyBlueprint
import DestinyDefaults

extension StaticRedirectionRoute {
    #if hasFeature(Embedded) || EMBEDDED
    /// The HTTP Message of this route. Computed at compile time.
    public func response() -> HTTPResponseMessage<StaticString> {
        var headers = HTTPHeaders()
        headers["date"] = HTTPDateFormat.placeholder
        return .redirect(to: to.joined(separator: "/"), version: version, status: status, headers: &headers)
    }
    #else
    /// The HTTP Message of this route. Computed at compile time.
    public func response() -> HTTPResponseMessage {
        var headers = HTTPHeaders()
        headers["date"] = HTTPDateFormat.placeholder
        return .redirect(to: to.joined(separator: "/"), version: version, status: status, headers: &headers)
    }
    #endif
}

#endif