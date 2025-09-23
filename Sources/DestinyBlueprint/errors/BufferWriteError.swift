
/// An `Error` that indicates failure when writing a buffer.
public enum BufferWriteError: DestinyErrorProtocol {
    case custom(errno: Int32)
    case custom(reason: String)
}