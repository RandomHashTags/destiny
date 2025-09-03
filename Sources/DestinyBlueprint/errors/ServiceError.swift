
public struct ServiceError: DestinyErrorProtocol {
    public let identifier:String
    public let reason:String

    public init(identifier: String, reason: String) {
        self.identifier = identifier
        self.reason = reason
    }
}

extension ServiceError {
    #if Inlinable
    @inlinable
    #endif
    public static func serverError(_ error: ServerError) -> Self {
        Self(identifier: "serverError", reason: "\(error)")
    }
}