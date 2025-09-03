
public struct SocketError: DestinyErrorProtocol {
    public let identifier:String
    public let reason:String

    public init(identifier: String, reason: String) {
        self.identifier = identifier
        self.reason = reason
    }
}

// MARK: Errors
extension SocketError {
    #if Inlinable
    @inlinable
    #endif
    public static func acceptFailed() -> Self {
        cError("acceptFailed")
    }

    #if Inlinable
    @inlinable
    #endif
    public static func acceptFailed(_ reason: String) -> Self {
        Self(identifier: "acceptFailed", reason: reason)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func writeFailed() -> Self {
        cError("writeFailed")
    }

    #if Inlinable
    @inlinable
    #endif
    public static func writeFailed(_ reason: String) -> Self {
        Self(identifier: "writeFailed", reason: reason)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func readSingleByteFailed() -> Self {
        cError("readSingleByteFailed")
    }

    #if Inlinable
    @inlinable
    #endif
    public static func readSingleByteFailed(_ reason: String) -> Self {
        Self(identifier: "readSingleByteFailed", reason: reason)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func readBufferFailed() -> Self {
        cError("readBufferFailed")
    }

    #if Inlinable
    @inlinable
    #endif
    public static func readBufferFailed(_ reason: String) -> Self {
        Self(identifier: "readBufferFailed", reason: reason)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func invalidStatus() -> Self {
        cError("invalidStatus")
    }

    #if Inlinable
    @inlinable
    #endif
    public static func invalidStatus(_ reason: String) -> Self {
        Self(identifier: "invalidStatus", reason: reason)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func closeFailure() -> Self {
        cError("closeFailure")
    }

    #if Inlinable
    @inlinable
    #endif
    public static func closeFailure(_ reason: String) -> Self {
        Self(identifier: "closeFailure", reason: reason)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func malformedRequest() -> Self {
        cError("malformedRequest")
    }

    #if Inlinable
    @inlinable
    #endif
    public static func malformedRequest(_ reason: String) -> Self {
        Self(identifier: "malformedRequest", reason: reason)
    }
}

extension SocketError {
    #if Inlinable
    @inlinable
    #endif
    public static func bufferWriteError(_ error: BufferWriteError) -> Self {
        Self(identifier: "bufferWriteError", reason: "\(error)")
    }
}