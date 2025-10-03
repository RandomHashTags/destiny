
public protocol NetworkAddressable: Sendable, ~Copyable {
    /// Local socket address of the file descriptor.
    func socketLocalAddress() -> String?

    /// Peer socket address of the file descriptor.
    func socketPeerAddress() -> String?
}