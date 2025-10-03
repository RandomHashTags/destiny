
/// An `Error` that indicates failure when handling Middleware.
public enum MiddlewareError {
    case socketError(SocketError)

    case errno(Int32)
    case custom(String)
}

// MARK: Conformances
extension MiddlewareError: Error {}