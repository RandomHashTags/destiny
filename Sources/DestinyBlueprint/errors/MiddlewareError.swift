
/// An `Error` that indicates failure when handling Middleware.
public enum MiddlewareError: DestinyErrorProtocol {
    case socketError(SocketError)

    case errno(Int32)
    case custom(String)
}