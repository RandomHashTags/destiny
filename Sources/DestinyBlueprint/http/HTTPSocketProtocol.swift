
/// Core Socket protocol that handles incoming http requests.
public protocol HTTPSocketProtocol: SocketProtocol, ~Copyable {
    associatedtype ConcreteRequest:HTTPRequestProtocol
}