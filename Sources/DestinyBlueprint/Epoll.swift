
#if os(Linux)
import CEpoll
import Glibc
import Logging

public struct Epoll<let maxEvents: Int>: SocketAcceptor {
    public let serverFD:Int32
    public let fileDescriptor:Int32
    public let pipeFileDescriptors:InlineArray<2, Int32>
    public let logger:Logger

    public init(serverFD: Int32, thread: Int) throws {
        self.serverFD = serverFD
        fileDescriptor = epoll_create1(0)
        if fileDescriptor == -1 {
            throw EpollError.epollCreateFailed()
        }
        var pipeFileDescriptors:InlineArray<2, Int32> = [0, 0]
        try pipeFileDescriptors.mutableSpan.withUnsafeBufferPointer {
            guard let base = $0.baseAddress else { throw EpollError.epollPipeFailed() }
            pipe(.init(mutating: base))
        }
        self.pipeFileDescriptors = pipeFileDescriptors
        logger = Logger(label: "epoll.destinyblueprint.\(serverFD).thread\(thread)")
        try add(client: serverFD, event: EPOLLIN.rawValue)
        try add(client: pipeFileDescriptors[0], event: EPOLLIN.rawValue)
        setNonBlocking(socket: self.fileDescriptor)
    }

    @inlinable
    public func setNonBlocking(socket: Int32) {
        let flags = fcntl(socket, F_GETFL, 0)
        guard flags != -1 else {
            fatalError("epoll;setNonBlocking;broken1")
        }
        let result = fcntl(socket, F_SETFL, flags | O_NONBLOCK)
        guard result != -1 else {
            fatalError("epoll;setNonBlocking;broken2")
        }
    }

    @inlinable
    public func add(client: Int32, event: UInt32) throws {
        var e = epoll_event()
        e.events = event
        e.data.fd = client
        if epoll_ctl(fileDescriptor, EPOLL_CTL_ADD, client, &e) == -1 {
            throw EpollError.epollCtlFailed()
        }
    }

    @inlinable
    public func remove(client: Int32) throws {
        if epoll_ctl(fileDescriptor, EPOLL_CTL_DEL, client, nil) == -1 {
            throw EpollError.epollCtlFailed()
        }
    }

    @inlinable
    public mutating func wait(
        timeout: Int32 = -1,
        acceptClient: (Int32) throws -> Int32?
    ) throws -> (loaded: Int, clients: InlineArray<maxEvents, Int32>) {
        var loadedClients:Int32 = -1
        var events = InlineArray<maxEvents, epoll_event>(repeating: .init())
        try events.mutableSpan.withUnsafeBufferPointer { p in
            guard let base = p.baseAddress else { throw EpollError.waitFailed() }
            loadedClients = epoll_pwait(fileDescriptor, .init(mutating: base), Int32(maxEvents), timeout, nil)
            if loadedClients == -1 {
                throw EpollError.waitFailed()
            }
        }
        var clients = InlineArray<maxEvents, Int32>(repeating: -1)
        var clientIndex = 0
        var i = 0
        while i < loadedClients {
            let event = events[i]
            if event.data.fd == serverFD {
                do {
                    if let client = try acceptClient(serverFD) {
                        setNonBlocking(socket: client)
                        do {
                            try add(client: client, event: EPOLLIN.rawValue)
                        } catch {
                            logger.warning("Encountered error trying to add accepted client to epoll: \(error) (errno=\(errno))")
                            closeSocket(client, name: "accepted client")
                        }
                    }
                } catch {
                    logger.warning("Encountered error trying to accept client (\(event.data.fd)): \(error) (errno=\(errno))")
                }
            } else if event.events & EPOLLIN.rawValue != 0 {
                clients[clientIndex] = event.data.fd
                clientIndex += 1
            } else if event.events & EPOLLHUP.rawValue != 0 {
                closeSocket(event.data.fd, name: "client disconnected")
            } else if event.events & EPOLLERR.rawValue != 0 {
                closeSocket(event.data.fd, name: "client's socket errored")
            }
            i += 1
        }
        return (clientIndex, clients)
    }

    @inlinable
    public func closeSocket(_ socket: Int32, name: String) {
        let closed = close(socket)
        if closed < 0 {
            logger.warning("Failed to close socket with name: \(name) (errno=\(errno))")
        }
    }

    @inlinable
    public func closeFileDescriptor() {
        closeSocket(fileDescriptor, name: "Epoll fileDescriptor")
    }
}

#endif