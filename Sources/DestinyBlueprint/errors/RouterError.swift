
/// An `Error` that indicates failure when handling a Router.
public enum RouterError: DestinyErrorProtocol {
    case errno(Int32)
    case custom(String)
}