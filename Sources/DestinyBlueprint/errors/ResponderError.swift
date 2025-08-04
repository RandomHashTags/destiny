
public struct ResponderError: DestinyErrorProtocol {
    public let identifier:String
    public let reason:String

    public init(identifier: String, reason: String) {
        self.identifier = identifier
        self.reason = reason
    }
}

extension ResponderError {
    @inlinable public static func socketError(_ error: SocketError) -> Self { Self(identifier: "socketError", reason: "\(error)") }
    @inlinable public static func middlewareError(_ error: MiddlewareError) -> Self { Self(identifier: "middlewareError", reason: "\(error)") }
}

extension ResponderError {
    @inlinable public static func inferred<E: Error>(_ error: E) -> Self { Self(identifier: "inferredError", reason: "\(error)") }
}