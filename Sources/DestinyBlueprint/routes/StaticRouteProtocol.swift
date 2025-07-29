
/// Core Static Route protocol where a complete HTTP Message is computed at compile time.
public protocol StaticRouteProtocol: RouteProtocol, ~Copyable {
    var startLine: String { get }

    /// Insert paths into this route's path at the given index.
    /// 
    /// Used by Route Groups at compile time.
    mutating func insertPath(
        contentsOf newElements: some Collection<String>,
        at i: Int
    )

    /// The `StaticRouteResponderProtocol` responder for this route.
    /// 
    /// - Parameters:
    ///   - middleware: Static middleware that this route will apply.
    /// - Throws: any error.
    func responder(
        middleware: [any StaticMiddlewareProtocol]
    ) throws -> (any StaticRouteResponderProtocol)?
}