
public protocol HTTPCookieProtocol: CustomStringConvertible, Sendable {
    associatedtype CookieName = String
    associatedtype CookieValue = String

    /// Name of the cookie.
    func name() -> CookieName

    /// Sets the name of the cookie.
    mutating func setName(_ name: String) throws(HTTPCookieError)

    /// Value of the cookie.
    func value() -> CookieValue

    /// Sets the value of the cookie.
    mutating func setValue(_ value: String) throws(HTTPCookieError)

    /// Maximum age this cookie is valid for.
    var maxAge: UInt64 { get set }

    var domain: String? { get set }
    var path: String? { get set }

    var isSecure: Bool { get set }
    var isHTTPOnly: Bool { get set }
}