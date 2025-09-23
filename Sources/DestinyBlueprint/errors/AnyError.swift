
/// An `Error` that indicates failure when handling anything.
public enum AnyError: DestinyErrorProtocol {
    case httpCookieError(HTTPCookieError)

    case custom(errno: Int32)
    case custom(reason: String)
}