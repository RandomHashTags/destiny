
/// An `Error` that indicates failure when handling an HTTP Message.
public enum HTTPMessageError {
    case errno(Int32)
    case custom(String)
}

// MARK: Conformances
extension HTTPMessageError: Error {}