
/// An `Error` that indicates failure when handling a Service.
public enum ServiceError {
    case serverError(ServerError)

    case errno(Int32)
    case custom(String)
}

// MARK: Conformances
extension ServiceError: Error {}