
/// Types conforming to this protocol indicate they handle sockets/file descriptors.
public protocol SocketProvider: Sendable, ~Copyable {
    /// The file descriptor this socket provider is listening on.
    var fileDescriptor: Int32 { get }

    #if Epoll
    /// Rearms a file descriptor so it can be triggered by `epoll_pwait`.
    func rearm(fd: Int32)
    #endif
}