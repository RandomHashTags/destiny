
/// An `Error` that indicates failure when handling an HTTP Cookie.
public enum HTTPCookieError: DestinyErrorProtocol {
    case illegalCharacter(Character)

    case custom(errno: Int32)
    case custom(reason: String)
}