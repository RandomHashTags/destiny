
import DestinyBlueprint

/// Core Dynamic Route protocol where a complete HTTP Message, computed at compile time, is modified upon requests.
public protocol DynamicRouteProtocol: RouteProtocol {
    associatedtype ConcreteDynamicResponse:DynamicResponseProtocol

    /// Default status of this route. May be modified by static middleware at compile time or by dynamic middleware upon requests.
    var status: HTTPResponseStatus.Code { get set }

    /// Default content type of this route. May be modified by static middleware at compile time or dynamic middleware upon requests.
    var contentType: HTTPMediaType? { get set }

    /// Path of this route.
    var path: [PathComponent] { get set }

    /// Default HTTP Message computed by default values and static middleware.
    var defaultResponse: ConcreteDynamicResponse { get set }

    /// - Returns: The responder for this route.
    func responder() -> any DynamicRouteResponderProtocol

    /// Applies static middleware to this route.
    /// 
    /// - Parameters:
    ///   - middleware: The static middleware to apply to this route.
    mutating func applyStaticMiddleware(_ middleware: [some StaticMiddlewareProtocol])
}

extension DynamicRouteProtocol {
    @inlinable
    public var startLine: String {
        return method.rawNameString() + " /" + path.map({ $0.slug }).joined(separator: "/") + " " + version.string
    }
}