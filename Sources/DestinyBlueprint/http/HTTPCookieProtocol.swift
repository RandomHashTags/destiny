
public protocol HTTPCookieProtocol: CustomStringConvertible, Sendable {
    associatedtype CookieName = String
    associatedtype CookieValue = String

    func name() -> CookieName
    mutating func setName(_ name: String) throws(HTTPCookieError)

    func value() -> CookieValue
    mutating func setValue(_ value: String) throws(HTTPCookieError)

    var maxAge: UInt64 { get set }

    var domain: String? { get set }
    var path: String? { get set }

    var isSecure: Bool { get set }
    var isHTTPOnly: Bool { get set }
}