
/// Something that can have a local or peer network address.
public protocol NetworkAddressable: Sendable, ~Copyable {
    /// Local socket address of the file descriptor.
    func socketLocalAddress() -> String?

    /// Peer socket address of the file descriptor.
    func socketPeerAddress() -> String?
}