
import DestinyEmbedded

public struct HTTPResponseMessageHead<
        Cookie: HTTPCookieProtocol
    >: Sendable {

    public var headers:HTTPHeaders
    public var cookies:[Cookie]
    public var status:HTTPResponseStatus.Code
    public var version:HTTPVersion

    public init(
        headers: HTTPHeaders,
        cookies: [Cookie],
        status: HTTPResponseStatus.Code,
        version: HTTPVersion
    ) {
        self.headers = headers
        self.cookies = cookies
        self.status = status
        self.version = version
    }

    #if Inlinable
    @inlinable
    #endif
    public func string(escapeLineBreak: Bool) -> String {
        return string(suffix: escapeLineBreak ? "\\r\\n" : "\r\n")
    }

    #if Inlinable
    @inlinable
    #endif
    public func string(suffix: String) -> String {
        var string = "\(version.string) \(status)\(suffix)"
        for (header, value) in headers {
            string += "\(header): \(value)\(suffix)"
        }
        for cookie in cookies {
            string += "set-cookie: \(cookie)\(suffix)"
        }
        return string
    }

    #if Inlinable
    @inlinable
    #endif
    public func cookieDescriptions() -> [String] {
        var array = [String]()
        array.reserveCapacity(cookies.count)
        for cookie in cookies {
            array.append("\(cookie)")
        }
        return array
    }
}

#if canImport(DestinyBlueprint)
import DestinyBlueprint
#endif