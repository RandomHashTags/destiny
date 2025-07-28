
/// Core Route Responder protocol that writes its responses to requests.
public protocol RouteResponderProtocol: Sendable, ~Copyable {
}

// MARK: Default conformances
extension String: RouteResponderProtocol {}
extension StaticString: RouteResponderProtocol {}
extension [UInt8]: RouteResponderProtocol {}