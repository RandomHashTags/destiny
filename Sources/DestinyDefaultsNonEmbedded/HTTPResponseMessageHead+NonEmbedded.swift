
import DestinyBlueprint
import DestinyDefaults

// MARK: Init
extension HTTPResponseMessageHead {
    public init(
        headers: HTTPHeaders,
        cookies: [any HTTPCookieProtocol],
        status: HTTPResponseStatus.Code,
        version: HTTPVersion
    ) throws(HTTPCookieError) {
        var concreteCookies = [Cookie]()
        concreteCookies.reserveCapacity(cookies.count)
        for c in cookies {
            try concreteCookies.append(.init(copying: c))
        }
        self.init(
            headers: headers,
            cookies: concreteCookies,
            status: status,
            version: version
        )
    }

    public init(
        headers: HTTPHeaders,
        cookies: [some HTTPCookieProtocol],
        status: HTTPResponseStatus.Code,
        version: HTTPVersion
    ) throws(HTTPCookieError) {
        var concreteCookies = [Cookie]()
        concreteCookies.reserveCapacity(cookies.count)
        for c in cookies {
            try concreteCookies.append(.init(copying: c))
        }
        self.init(
            headers: headers,
            cookies: concreteCookies,
            status: status,
            version: version
        )
    }
}