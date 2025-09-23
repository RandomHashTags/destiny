
// MARK: ServerError
/// An `Error` that indicates failure when handling a Server.
public enum ServerError: DestinyErrorProtocol {
    case socketCreationFailed(errno: Int32)
    case socketCreationFailed(reason: String)

    case bindFailed(errno: Int32)
    case bindFailed(reason: String)

    case listenFailed(errno: Int32)
    case listenFailed(reason: String)

    case routerError(RouterError)

    case custom(errno: Int32)
    case custom(reason: String)
}