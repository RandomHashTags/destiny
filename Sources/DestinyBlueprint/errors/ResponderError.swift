
/// An `Error` that indicates failure when handling a route responder.
public enum ResponderError: DestinyErrorProtocol {
    case middlewareError(MiddlewareError)
    case socketError(SocketError)

    case custom(errno: Int)
    case custom(reason: String)
}