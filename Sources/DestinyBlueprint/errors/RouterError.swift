
/// An `Error` that indicates failure when handling a Router.
public enum RouterError: DestinyErrorProtocol {
    case custom(errno: Int32)
    case custom(reason: String)
}