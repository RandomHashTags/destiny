
/// An `Error` that indicates failure when handling anything.
public struct AnyError: DestinyErrorProtocol {
    public let identifier:String
    public let reason:String

    public init(identifier: String, reason: String) {
        self.identifier = identifier
        self.reason = reason
    }
}

extension AnyError {
    #if Inlinable
    @inlinable
    #endif
    public static func httpCookieError(_ error: HTTPCookieError) -> Self {
        Self(identifier: "httpCookieError_\(error.identifier)", reason: error.reason)
    }
}