
/// An `Error` that indicates failure when handling Middleware.
public enum MiddlewareError: DestinyErrorProtocol {
    case socketError(SocketError)

    case custom(errno: Int32)
    case custom(reason: String)
}