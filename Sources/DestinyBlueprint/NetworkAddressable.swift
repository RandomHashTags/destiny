
public protocol NetworkAddressable: Sendable, ~Copyable {
    /// Local socket address of this file descriptor.
    func socketLocalAddress() -> String?

    /// Peer socket address of this file descriptor.
    func socketPeerAddress() -> String?
}