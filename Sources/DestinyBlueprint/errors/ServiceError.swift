
/// An `Error` that indicates failure when handling a Service.
public enum ServiceError: DestinyErrorProtocol {
    case serverError(ServerError)

    case errno(Int32)
    case custom(String)
}