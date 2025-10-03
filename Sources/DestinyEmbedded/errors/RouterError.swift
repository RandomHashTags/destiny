
/// An `Error` that indicates failure when handling a Router.
public enum RouterError {
    case errno(Int32)
    case custom(String)
}

// MARK: Conformances
extension RouterError: Error {}