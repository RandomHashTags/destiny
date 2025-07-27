
/// Core Route protocol.
public protocol RouteProtocol: Sendable, ~Copyable {
    /// `HTTPVersion` associated with this route.
    var version: HTTPVersion { get }
    
    /// HTTP Request Method of this route.
    var method: any HTTPRequestMethodProtocol { get }

    /// Whether or not the path for this route is case-sensitive.
    var isCaseSensitive: Bool { get }
}