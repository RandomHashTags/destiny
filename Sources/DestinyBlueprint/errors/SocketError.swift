
/// An `Error` that indicates failure when handling an HTTP Socket.
public enum SocketError: DestinyErrorProtocol {
    case acceptFailed(errno: Int32)
    case acceptFailed(reason: String)

    case writeFailed(errno: Int32)
    case writeFailed(reason: String)

    case readSingleByteFailed(errno: Int32)
    case readSingleByteFailed(reason: String)

    case readBufferFailed(errno: Int32)
    case readBufferFailed(reason: String)

    case invalidStatus(errno: Int32)
    case invalidStatus(reason: String)

    case closeFailure(errno: Int32)
    case closeFailure(reason: String)

    case malformedRequest(errno: Int32)
    case malformedRequest(reason: String)

    case bufferWriteError(BufferWriteError)

    case custom(errno: Int32)
    case custom(reason: String)
}