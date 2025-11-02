
/// An `Error` that indicates failure when handling an HTTP Socket.
public enum SocketError {
    case acceptFailed(errno: Int32)
    case writeFailed(errno: Int32)

    case readZero
    case readSingleByteFailed(errno: Int32)
    case readBufferFailed(errno: Int32)

    case invalidStatus(errno: Int32)
    case closeFailure(errno: Int32)
    case malformedRequest(errno: Int32)
    case bufferWriteError(BufferWriteError)

    case errno(Int32)
    case custom(String)
}

// MARK: Conformances
extension SocketError: Error {}