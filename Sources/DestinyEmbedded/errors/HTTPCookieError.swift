
/// An `Error` that indicates failure when handling an HTTP Cookie.
public enum HTTPCookieError {
    case illegalCharacter(Character)

    case errno(Int32)
    case custom(String)
}

// MARK: Conformances
extension HTTPCookieError: Error {}