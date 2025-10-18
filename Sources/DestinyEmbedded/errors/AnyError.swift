
/// An `Error` that indicates failure when handling anything.
public enum AnyError {
    #if HTTPCookie
    case httpCookieError(HTTPCookieError)
    #endif

    case errno(Int32)
    case custom(String)
}

// MARK: Conformances
extension AnyError: Error {}