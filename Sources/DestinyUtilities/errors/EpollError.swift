//
//  EpollError.swift
//
//
//  Created by Evan Anderson on 2/25/25.
//

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
    @inlinable public static func epollCreateFailed() -> Self { cError("epollCreateFailed") }
    @inlinable public static func epollCreateFailed(_ reason: String) -> Self { Self(identifier: "epollCreateFailed", reason: reason) }

    @inlinable public static func epollCtlFailed() -> Self { cError("epollCtlFailed") }
    @inlinable public static func epollCtlFailed(_ reason: String) -> Self { Self(identifier: "epollCtlFailed", reason: reason) }

    @inlinable public static func waitFailed() -> Self { cError("waitFailed") }
    @inlinable public static func waitFailed(_ reason: String) -> Self { Self(identifier: "waitFailed", reason: reason) }
}