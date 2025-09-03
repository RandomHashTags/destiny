
/// Core Static Route Responder protocol that handles requests to static routes.
public protocol NonCopyableStaticRouteResponderProtocol: NonCopyableRouteResponderProtocol, ~Copyable {
}

// MARK: Default conformances
extension String: NonCopyableStaticRouteResponderProtocol {}
extension StaticString: NonCopyableStaticRouteResponderProtocol {}
extension [UInt8]: NonCopyableStaticRouteResponderProtocol {}