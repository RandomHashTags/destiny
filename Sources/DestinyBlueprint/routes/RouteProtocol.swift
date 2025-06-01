
import SwiftCompression

/// Core Route protocol.
public protocol RouteProtocol: CustomDebugStringConvertible, Sendable {
    /// `HTTPVersion` associated with this route.
    var version: HTTPVersion { get }
    
    /// HTTP Request Method of this route.
    var method: any HTTPRequestMethodProtocol { get }

    /// Supported compression algorithms this route can use to compress its response.
    var supportedCompressionAlgorithms: Set<CompressionAlgorithm> { get set }

    /// Whether or not the path for this route is case-sensitive.
    var isCaseSensitive: Bool { get }
}