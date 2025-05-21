
#if os(Linux)
import CEpoll
import Glibc
import Logging
import ServiceLifecycle

extension Server where ClientSocket: ~Copyable {
    @discardableResult
    @inlinable
    func processClientsEpoll<let threads: Int, let maxEvents: Int>(
        serverFD: Int32,
        router: ConcreteRouter
    ) async -> InlineArray<threads, InlineArray<maxEvents, Bool>>? {
        setNonBlocking(socket: serverFD)
        do {
            let processor = try EpollProcessor<threads, maxEvents, ClientSocket>(
                serverFD: serverFD
            )
            await processor.run(timeout: -1, router: router, noTCPDelay: noTCPDelay)
            for i in processor.instances.indices {
                processor.instances[i].closeFileDescriptor()
            }
        } catch {
            print("epoll;processClientsEpoll;broken")
        }
        return nil
    }

    @inlinable
    func setNonBlocking(socket: Int32) {
        let flags = fcntl(socket, F_GETFL, 0)
        guard flags != -1 else {
            fatalError("epoll;setNonBlocking;broken1")
        }
        let result = fcntl(socket, F_SETFL, flags | O_NONBLOCK)
        guard result != -1 else {
            fatalError("epoll;setNonBlocking;broken2")
        }
    }
}

// MARK: Epoll
public struct Epoll<let maxEvents: Int>: SocketAcceptor {
    public let serverFD:Int32
    public let fileDescriptor:Int32
    public let logger:Logger

    public init(serverFD: Int32, thread: Int) throws {
        self.serverFD = serverFD
        fileDescriptor = epoll_create1(0)
        if fileDescriptor == -1 {
            throw EpollError.epollCreateFailed()
        }
        logger = Logger(label: "destiny.epoll.\(serverFD).thread\(thread)")
        try add(client: serverFD, event: EPOLLIN.rawValue)
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
        acceptClient: (Int32) throws -> (Int32, ContinuousClock.Instant)?
    ) throws -> (loaded: Int, clients: InlineArray<maxEvents, Int32>) {
        var loadedClients:Int32 = -1
        var events = InlineArray<maxEvents, epoll_event>(repeating: .init())
        try events.mutableSpan.withUnsafeBufferPointer { p in
            guard let base = p.baseAddress else { throw EpollError.waitFailed() }
            loadedClients = epoll_wait(fileDescriptor, .init(mutating: base), Int32(maxEvents), timeout)
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
                    if let (client, instant) = try acceptClient(serverFD) {
                        setNonBlocking(socket: client)
                        do {
                            try add(client: client, event: EPOLLIN.rawValue)
                        } catch {
                            logger.warning(Logger.Message(stringLiteral: "Encountered error trying to add accepted client to epoll: \(error) (errno=\(errno))"))
                            closeSocket(client, name: "accepted client")
                        }
                    }
                } catch {
                    logger.warning(Logger.Message(stringLiteral: "Encountered error trying to accept client (\(event.data.fd)): \(error) (errno=\(errno))"))
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
            logger.warning(Logger.Message(stringLiteral: "Failed to close socket with name: \(name) (errno=\(errno))"))
        }
    }

    @inlinable
    public func closeFileDescriptor() {
        closeSocket(fileDescriptor, name: "Epoll fileDescriptor")
    }
}

// MARK: EpollProcessor
public struct EpollProcessor<let threads: Int, let maxEvents: Int, ConcreteSocket: SocketProtocol & ~Copyable>: Sendable, ~Copyable {
    public let instances:InlineArray<threads, Epoll<maxEvents>>

    @inlinable
    public init(
        serverFD: Int32
    ) throws {
        var i = 0
        instances = try .init(
            first: .init(serverFD: serverFD, thread: i),
            next: { _ in
                let e = try Epoll<maxEvents>.init(serverFD: serverFD, thread: i)
                i += 1
                return e
            }
        )
    }

    @inlinable
    public func add(client: Int32, event: UInt32) throws {
        try instances[Int(client) % threads].add(client: client, event: event)
    }

    @inlinable
    public func run<ConcreteRouter: RouterProtocol>(
        timeout: Int32,
        router: ConcreteRouter,
        noTCPDelay: Bool
    ) async {
        await withTaskGroup { group in
            for i in instances.indices {
                var instance = instances[i]
                group.addTask {
                    await Self.process(&instance, timeout: timeout, router: router, noTCPDelay: noTCPDelay)
                }
            }
            await group.waitForAll()
            // TODO: fix | doesn't cancel when graceful shutdown is triggered
        }
    }

    @inlinable
    public static func process<ConcreteRouter: RouterProtocol>(
        _ instance: inout Epoll<maxEvents>,
        timeout: Int32,
        router: ConcreteRouter,
        noTCPDelay: Bool
    ) async {
        let logger = instance.logger
        let acceptClient = instance.acceptFunction(noTCPDelay: noTCPDelay)
        while !Task.isCancelled && !Task.isShuttingDownGracefully {
            do {
                let (loaded, clients) = try instance.wait(timeout: timeout, acceptClient: acceptClient)
                let received = ContinuousClock.now
                var i = 0
                while i < loaded {
                    let client = clients[i]
                    do {
                        try instance.remove(client: client)
                    } catch {
                        instance.logger.warning(Logger.Message(stringLiteral: "Encountered error while removing client: \(error)"))
                    }
                    Task.detached {
                        do {
                            try await router.process(
                                client: client,
                                received: received,
                                socket: ConcreteSocket.init(fileDescriptor: client),
                                logger: logger
                            )
                        } catch {
                            logger.warning(Logger.Message(stringLiteral: "Encountered error while processing client: \(error)"))
                        }
                    }
                    i += 1
                }
            } catch {
                instance.logger.warning(Logger.Message(stringLiteral: "Encountered error while waiting for client: \(error)"))
            }
        }
        print("EpollProcessor;process;finished")
        // TODO: fix (this doesn't get executed when the service is shutdown)
    }
}

#endif