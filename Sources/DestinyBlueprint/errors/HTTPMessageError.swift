
/// An `Error` that indicates failure when handling an HTTP Message.
public enum HTTPMessageError: DestinyErrorProtocol {
    case custom(errno: Int32)
    case custom(reason: String)
}