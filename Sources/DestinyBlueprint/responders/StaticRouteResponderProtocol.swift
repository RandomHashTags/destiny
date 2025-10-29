
/// Core protocol that handles requests to static routes.
public protocol StaticRouteResponderProtocol: RouteResponderProtocol, ~Copyable {
}

// MARK: Default conformances

#if StringRouteResponder
extension String: StaticRouteResponderProtocol {}
#endif

extension StaticString: StaticRouteResponderProtocol {}
extension [UInt8]: StaticRouteResponderProtocol {}