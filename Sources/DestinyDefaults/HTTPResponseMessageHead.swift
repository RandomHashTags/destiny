
import DestinyBlueprint

public struct HTTPResponseMessageHead: Sendable {
    public var headers:HTTPHeaders
    public var cookies:[any HTTPCookieProtocol]
    public var status:HTTPResponseStatus.Code
    public var version:HTTPVersion

    public init(
        headers: HTTPHeaders,
        cookies: [any HTTPCookieProtocol],
        status: HTTPResponseStatus.Code,
        version: HTTPVersion
    ) {
        self.headers = headers
        self.cookies = cookies
        self.status = status
        self.version = version
    }

    @inlinable
    public func string(escapeLineBreak: Bool) -> String {
        return string(suffix: escapeLineBreak ? "\\r\\n" : "\r\n")
    }

    @inlinable
    public func string(suffix: String) -> String {
        var string = "\(version.string) \(status)\(suffix)"
        for (header, value) in headers {
            string += "\(header): \(value)\(suffix)"
        }
        for cookie in cookies {
            string += "Set-Cookie: \(cookie)\(suffix)"
        }
        return string
    }
}