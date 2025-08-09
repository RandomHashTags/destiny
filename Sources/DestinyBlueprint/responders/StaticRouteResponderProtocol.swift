
/// Core Static Route Responder protocol that handles requests to static routes.
public protocol StaticRouteResponderProtocol: RouteResponderProtocol, HTTPSocketWritable, ~Copyable {
}

// MARK: Default conformances
extension String: StaticRouteResponderProtocol {}
extension StaticString: StaticRouteResponderProtocol {}
extension [UInt8]: StaticRouteResponderProtocol {}