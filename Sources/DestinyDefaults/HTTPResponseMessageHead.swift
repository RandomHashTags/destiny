
import DestinyEmbedded

/// Default storage that efficiently handles an HTTP Message's head content (HTTP Version, status code and headers).
public struct HTTPResponseMessageHead: Sendable {
    public var headers:HTTPHeaders

    #if HTTPCookie
    public var cookies:[HTTPCookie]
    #endif

    public var status:HTTPResponseStatus.Code
    public var version:HTTPVersion

    #if HTTPCookie
    public init(
        headers: HTTPHeaders,
        cookies: [HTTPCookie],
        status: HTTPResponseStatus.Code,
        version: HTTPVersion
    ) {
        self.headers = headers
        self.cookies = cookies
        self.status = status
        self.version = version
    }
    #else
    public init(
        headers: HTTPHeaders,
        status: HTTPResponseStatus.Code,
        version: HTTPVersion
    ) {
        self.headers = headers
        self.status = status
        self.version = version
    }
    #endif

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

        #if HTTPCookie
        for cookie in cookies {
            string += "set-cookie: \(cookie)\(suffix)"
        }
        #endif

        return string
    }

    #if HTTPCookie
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
    #endif
}