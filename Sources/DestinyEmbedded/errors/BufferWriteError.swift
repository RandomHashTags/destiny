
/// An `Error` that indicates failure when writing a buffer.
public enum BufferWriteError {
    case errno(Int32)
    case custom(String)
}

// MARK: Conformances
extension BufferWriteError: Error {}