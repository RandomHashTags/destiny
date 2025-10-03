
/// An `Error` that indicates failure when handling anything.
public enum AnyError {
    case httpCookieError(HTTPCookieError)

    case errno(Int32)
    case custom(String)
}

// MARK: Conformances
extension AnyError: Error {}