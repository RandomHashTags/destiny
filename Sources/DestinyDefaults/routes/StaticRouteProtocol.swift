
import DestinyBlueprint

/// Core Static Route protocol where a complete HTTP Message is computed at compile time.
public protocol StaticRouteProtocol: RouteProtocol {
    var startLine: String { get }

    mutating func insertPath<C: Collection<String>>(contentsOf newElements: C, at i: Int)

    /// The HTTP Message of this route.
    /// 
    /// - Parameters:
    ///   - middleware: Static middleware that this route will apply.
    /// - Returns: An `HTTPResponseMessage`.
    /// - Warning: You should apply any statuses and headers using the middleware.
    func response(
        middleware: [any StaticMiddlewareProtocol]
    ) -> any HTTPMessageProtocol

    /// The `StaticRouteResponderProtocol` responder for this route.
    /// 
    /// - Parameters:
    ///   - middleware: Static middleware that this route will apply.
    /// - Throws: any error.
    func responder(
        middleware: [any StaticMiddlewareProtocol]
    ) throws -> (any StaticRouteResponderProtocol)?
}