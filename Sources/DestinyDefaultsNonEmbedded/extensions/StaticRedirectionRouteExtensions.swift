
import DestinyBlueprint
import DestinyDefaults

extension StaticRedirectionRoute {
    /// The HTTP Message of this route. Computed at compile time.
    public func response() -> HTTPResponseMessage {
        var headers = HTTPHeaders()
        headers["Date"] = HTTPDateFormat.placeholder
        return .redirect(to: to.joined(separator: "/"), version: version, status: status, headers: &headers)
    }
}