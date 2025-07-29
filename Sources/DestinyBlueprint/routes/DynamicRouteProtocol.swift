
/// Core Dynamic Route protocol where a complete HTTP Message, computed at compile time, is modified upon requests.
public protocol DynamicRouteProtocol: RouteProtocol {
    var pathCount: Int { get }

    /// Whether or not this route accepts any value at any of its paths.
    var pathContainsParameters: Bool { get }

    /// - Returns: The responder for this route.
    func responder() -> any DynamicRouteResponderProtocol

    /// Applies static middleware to this route.
    /// 
    /// - Parameters:
    ///   - middleware: The static middleware to apply to this route.
    mutating func applyStaticMiddleware(_ middleware: [some StaticMiddlewareProtocol])

    func startLine() -> String
}