
// MARK: ServerError
public struct ServerError: DestinyErrorProtocol {
    public let identifier:String
    public let reason:String

    public init(identifier: String, reason: String) {
        self.identifier = identifier
        self.reason = reason
    }
}

// MARK: Errors
extension ServerError {
    @inlinable public static func socketCreationFailed() -> Self { cError("socketCreationFailed") }
    @inlinable public static func socketCreationFailed(_ reason: String) -> Self { Self(identifier: "socketCreationFailed", reason: reason) }

    @inlinable public static func bindFailed() -> Self { cError("bindFailed") }
    @inlinable public static func bindFailed(_ reason: String) -> Self { Self(identifier: "bindFailed", reason: reason) }

    @inlinable public static func listenFailed() -> Self { cError("listenFailed") }
    @inlinable public static func listenFailed(_ reason: String) -> Self { Self(identifier: "listenFailed", reason: reason) }
}