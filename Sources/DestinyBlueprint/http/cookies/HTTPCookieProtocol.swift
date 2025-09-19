
public protocol HTTPCookieProtocol: CustomStringConvertible, Sendable {
    /// Maximum age this cookie is valid for.
    var maxAge: UInt64 { get set }

    var expiresString: String? { get set }
    var domain: String? { get set }
    var path: String? { get set }

    var sameSite: HTTPCookieFlag.SameSite? { get set }

    var isSecure: Bool { get set }
    var isHTTPOnly: Bool { get set }

    init(copying source: some HTTPCookieProtocol) throws(HTTPCookieError)

    /// Name of the cookie.
    func name() -> String

    /// Sets the name of the cookie.
    mutating func setName(_ name: String) throws(HTTPCookieError)

    /// Value of the cookie.
    func value() -> String

    /// Sets the value of the cookie.
    mutating func setValue(_ value: String) throws(HTTPCookieError)
}