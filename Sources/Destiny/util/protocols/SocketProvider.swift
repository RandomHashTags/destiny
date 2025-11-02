
public protocol SocketProvider: Sendable, ~Copyable {
    var fileDescriptor: Int32 { get }


    #if Epoll
    func rearm(fd: Int32)
    #endif
}