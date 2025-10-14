
/// Core protocol where a complete HTTP Message, computed at compile time, is modified upon requests.
public protocol DynamicRouteProtocol: RouteProtocol, ~Copyable {
    /// Number of path components this route has. 
    var pathCount: Int { get }

    /// Whether or not this route accepts any value at any of its paths.
    var pathContainsParameters: Bool { get }

    /// Insert paths into this route's path at the given index.
    /// 
    /// Used by Route Groups at compile time.
    mutating func insertPath(
        contentsOf newElements: some Collection<PathComponent>,
        at i: Int
    )

    #if StaticMiddleware
    /// Applies static middleware to this route.
    /// 
    /// - Parameters:
    ///   - middleware: Static middleware to apply to this route.
    /// 
    /// - Throws: `AnyError`
    mutating func applyStaticMiddleware(
        _ middleware: [some StaticMiddlewareProtocol]
    ) throws(AnyError)
    #endif

    func startLine() -> String
}