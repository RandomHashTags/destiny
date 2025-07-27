
public protocol HTTPCookieProtocol: CustomStringConvertible, Sendable {
    associatedtype CookieName = String
    associatedtype CookieValue = String

    associatedtype Expires

    var name: CookieName { get set }
    var value: CookieValue { get set }

    var maxAge: UInt64 { get set }

    var expires: Expires? { get set }

    var domain: String? { get set }
    var path: String? { get set }

    var isSecure: Bool { get set }
    var isHTTPOnly: Bool { get set }
}