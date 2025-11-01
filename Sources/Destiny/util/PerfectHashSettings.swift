
/// Configurable settings that change how perfect hashing behaves.
public struct PerfectHashSettings: Sendable {
    /// Number of route path characters to try generating perfect hashes from.
    public let maxBytes:[Int]

    /// Route paths that don't require exact matching to respond.
    /// 
    /// - Warning: These route paths allow for 'random' request paths to respond with a route's responder if the hash keys match.
    public let relaxedRoutePaths:Set<String>

    /// Whether or not route paths require exact matching to respond.
    /// 
    /// Adds a check to verify the request's target path and the route's path are equal (costs a minor performance hit).
    /// 
    /// - Warning: If `false`: allows for 'random' request paths to respond with a route's responder if the hash keys match.
    public let requireExactPaths:Bool

    /// Whether or not to try calculating perfect hashes for route paths.
    public let enabled:Bool

    public init(
        enabled: Bool = true,
        maxBytes: [Int] = [1, 2, 3, 4, 5, 6, 7, 8],
        requireExactPaths: Bool = true,
        relaxedRoutePaths: Set<String> = []
    ) {
        self.enabled = enabled
        self.maxBytes = maxBytes
        self.requireExactPaths = requireExactPaths
        self.relaxedRoutePaths = relaxedRoutePaths
    }
}