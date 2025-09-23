
/// An `Error` that indicates failure when handling anything.
public enum AnyError: DestinyErrorProtocol {
    case httpCookieError(HTTPCookieError)

    case errno(Int32)
    case custom(String)
}