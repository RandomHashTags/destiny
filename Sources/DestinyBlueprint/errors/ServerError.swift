
/// An `Error` that indicates failure when handling a Server.
public enum ServerError: DestinyErrorProtocol {
    case socketCreationFailed(errno: Int32)
    case bindFailed(errno: Int32)
    case listenFailed(errno: Int32)
    case routerError(RouterError)

    case errno(Int32)
    case custom(String)
}