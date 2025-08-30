
/// Configurable settings that change how perfect hashing behaves.
public struct PerfectHashSettings { // TODO: actually adopt in the macro
    /// Number of route path characters to try generating perfect hashes from.
    /// 
    /// - Warning: Needs to be a power of 2 (2, 4, 8, 16, 32, 64).
    public let maxBytes:[Int]

    /// Whether or not route paths require exact matching to respond.
    /// 
    /// Adds a check to verify the request's target path and the route's path are equal (costs a minor performance hit).
    /// 
    /// - Note: Only used by the macro expansion.
    /// - Warning: If `false`: allows for 'random' request paths to respond with a route's responder if the hash keys match.
    public let requireExactPaths:Bool

    /// Route paths that don't require exact matching to respond.
    /// 
    /// - Note: Only used by the macro expansion.
    /// - Warning: All route paths listed allow for 'random' request paths to respond with a route's responder if the hash keys match.
    public let relaxedRoutePaths:Set<String>

    public init(
        maxBytes: [Int] = [2, 4, 8, 16, 32, 64],
        requireExactPaths: Bool = true,
        relaxedRoutePaths: Set<String> = []
    ) {
        self.maxBytes = maxBytes
        self.requireExactPaths = requireExactPaths
        self.relaxedRoutePaths = relaxedRoutePaths
    }
}