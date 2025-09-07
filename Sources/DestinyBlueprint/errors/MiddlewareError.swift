
public struct MiddlewareError: DestinyErrorProtocol {
    public let identifier:String
    public let reason:String

    public init(identifier: String, reason: String) {
        self.identifier = identifier
        self.reason = reason
    }
}

extension MiddlewareError {
    #if Inlinable
    @inlinable
    #endif
    public static func socketError(_ error: SocketError) -> Self {
        Self(identifier: "socketError", reason: "\(error)")
    }
}