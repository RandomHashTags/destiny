
/// An `Error` that indicates failure when handling a Service.
public enum ServiceError: DestinyErrorProtocol {
    case serverError(ServerError)

    case custom(errno: Int32)
    case custom(reason: String)
}