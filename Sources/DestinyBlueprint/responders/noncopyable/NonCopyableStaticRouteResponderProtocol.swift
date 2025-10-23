
#if NonCopyable

/// Core protocol that handles requests to static routes.
public protocol NonCopyableStaticRouteResponderProtocol: NonCopyableRouteResponderProtocol, ~Copyable {
}

// MARK: Default conformances

#if StringRouteResponder
extension String: NonCopyableStaticRouteResponderProtocol {}
#endif

extension StaticString: NonCopyableStaticRouteResponderProtocol {}
extension [UInt8]: NonCopyableStaticRouteResponderProtocol {}

#endif