
/// List of supported i/o systems that handle networking sockets/file descriptors.
public enum SocketIOHandler {
    case epoll
    case kqueue
    case io_uring
    case swiftConcurrency
}

// MARK: isSupported
extension SocketIOHandler {
    /// Whether or not this handler is supported on your machine.
    #if Inlinable
    @inlinable
    #endif
    public var isSupported: Bool {
        switch self {
        case .epoll:
            #if Epoll
            return true
            #else
            return false
            #endif

        case .kqueue:
            #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS) || os(FreeBSD) || os(NetBSD) || os(OpenBSD)
            return true
            #else
            return false
            #endif

        case .io_uring:
            #if Liburing
            return true
            #else
            return false
            #endif

        case .swiftConcurrency:
            return true
        }
    }
}