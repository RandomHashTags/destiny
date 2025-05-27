
#if canImport(Darwin)
import Darwin
#endif

/// Core Socket protocol that handles incoming network requests.
public protocol HTTPSocketProtocol: SocketProtocol, ~Copyable {
    associatedtype ConcreteRequest:HTTPRequestProtocol
}