
/// An `Error` that indicates failure when handling an HTTP Message.
public enum HTTPMessageError: DestinyErrorProtocol {
    case errno(Int32)
    case custom(String)
}