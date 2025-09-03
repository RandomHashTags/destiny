
public struct EpollError: DestinyErrorProtocol {
    public let identifier:String
    public let reason:String

    public init(identifier: String, reason: String) {
        self.identifier = identifier
        self.reason = reason
    }
}

// MARK: Errors
extension EpollError {
    #if Inlinable
    @inlinable
    #endif
    public static func epollCreateFailed() -> Self {
        cError("epollCreateFailed")
    }

    #if Inlinable
    @inlinable
    #endif
    public static func epollCreateFailed(_ reason: String) -> Self {
        Self(identifier: "epollCreateFailed", reason: reason)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func epollPipeFailed() -> Self {
        cError("epollPipeFailed")
    }

    #if Inlinable
    @inlinable
    #endif
    public static func epollPipeFailed(_ reason: String) -> Self {
        Self(identifier: "epollPipeFailed", reason: reason)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func epollCtlFailed() -> Self {
        cError("epollCtlFailed")
    }

    #if Inlinable
    @inlinable
    #endif
    public static func epollCtlFailed(_ reason: String) -> Self {
        Self(identifier: "epollCtlFailed", reason: reason)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func waitFailed() -> Self {
        cError("waitFailed")
    }

    #if Inlinable
    @inlinable
    #endif
    public static func waitFailed(_ reason: String) -> Self {
        Self(identifier: "waitFailed", reason: reason)
    }
}