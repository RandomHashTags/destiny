
/// An `Error` that indicates failure when writing a buffer.
public enum BufferWriteError: DestinyErrorProtocol {
    case errno(Int32)
    case custom(String)
}