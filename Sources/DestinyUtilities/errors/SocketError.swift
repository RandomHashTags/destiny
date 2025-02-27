//
//  SocketError.swift
//
//
//  Created by Evan Anderson on 2/25/25.
//

public struct SocketError : DestinyErrorProtocol {
    public let identifier:String
    public let reason:String

    public init(identifier: String, reason: String) {
        self.identifier = identifier
        self.reason = reason
    }
}

// MARK: Errors
extension SocketError {
    @inlinable public static func acceptFailed() -> Self { cError("acceptFailed") }
    @inlinable public static func acceptFailed(_ reason: String) -> Self { Self(identifier: "acceptFailed", reason: reason) }

    @inlinable public static func writeFailed() -> Self { cError("writeFailed") }
    @inlinable public static func writeFailed(_ reason: String) -> Self { Self(identifier: "writeFailed", reason: reason) }

    @inlinable public static func readSingleByteFailed() -> Self { cError("readSingleByteFailed") }
    @inlinable public static func readSingleByteFailed(_ reason: String) -> Self { Self(identifier: "readSingleByteFailed", reason: reason) }

    @inlinable public static func readBufferFailed() -> Self { cError("readBufferFailed") }
    @inlinable public static func readBufferFailed(_ reason: String) -> Self { Self(identifier: "readBufferFailed", reason: reason) }

    @inlinable public static func invalidStatus() -> Self { cError("invalidStatus") }
    @inlinable public static func invalidStatus(_ reason: String) -> Self { Self(identifier: "invalidStatus", reason: reason) }

    @inlinable public static func closeFailure() -> Self { cError("closeFailure") }
    @inlinable public static func closeFailure(_ reason: String) -> Self { Self(identifier: "closeFailure", reason: reason) }

    @inlinable public static func malformedRequest() -> Self { cError("malformedRequest") }
    @inlinable public static func malformedRequest(_ reason: String) -> Self { Self(identifier: "malformedRequest", reason: reason) }
}