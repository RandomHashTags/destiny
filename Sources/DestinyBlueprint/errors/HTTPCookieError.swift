
/// An `Error` that indicates failure when handling an HTTP Cookie.
public enum HTTPCookieError: DestinyErrorProtocol {
    case illegalCharacter(Character)

    case errno(Int32)
    case custom(String)
}