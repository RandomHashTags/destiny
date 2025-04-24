//
//  Epoll.swift
//
//
//  Created by Evan Anderson on 1/7/25.
//

#if os(Linux)
import CEpoll
import DestinyBlueprint
import Dispatch
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
            try await processor.run(timeout: -1, router: router, acceptClient: acceptFunction())
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
public struct Epoll<let maxEvents: Int>: Sendable {
    public let serverFD:Int32
    public let fileDescriptor:Int32
    public var events:InlineArray<maxEvents, epoll_event>
    public let logger:Logger

    public init(serverFD: Int32, thread: Int) throws {
        self.serverFD = serverFD
        fileDescriptor = epoll_create1(0)
        if fileDescriptor == -1 {
            throw EpollError.epollCreateFailed()
        }
        events = .init(repeating: epoll_event())
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
        try events.span.withUnsafeBufferPointer { p in
            guard let base = p.baseAddress else { throw EpollError.waitFailed() }
            loadedClients = epoll_wait(fileDescriptor, .init(mutating: base), Int32(maxEvents), timeout)
            if loadedClients == -1 {
                throw EpollError.waitFailed()
            } else if loadedClients == 0 {
                return
            }
        }
        var clients:InlineArray<maxEvents, Int32> = .init(repeating: -1)
        if loadedClients == 0 { return (0, clients) }
        var clientIndex = 0
        for i in 0..<Int(loadedClients) {
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
    public func run<Router: RouterProtocol>(
        timeout: Int32,
        router: Router,
        acceptClient: @escaping (Int32) throws -> (Int32, ContinuousClock.Instant)?
    ) async throws {
        await withTaskCancellationOrGracefulShutdownHandler {
            await withTaskGroup { group in
                for i in instances.indices {
                    var instance = instances[i]
                    group.addTask {
                        await Self.process(&instance, timeout: timeout, router: router, acceptClient: acceptClient)
                    }
                }
                await group.waitForAll()
                // TODO: fix | doesn't cancel when graceful shutdown is triggered
            }
        } onCancelOrGracefulShutdown: {
        }
    }

    @inlinable
    public static func process<Router: RouterProtocol>(
        _ instance: inout Epoll<maxEvents>,
        timeout: Int32,
        router: Router,
        acceptClient: (Int32) throws -> (Int32, ContinuousClock.Instant)?
    ) async {
        let logger = instance.logger
        while !Task.isCancelled && !Task.isShuttingDownGracefully {
            do {
                let (loaded, clients) = try instance.wait(timeout: timeout, acceptClient: acceptClient)
                for i in 0..<loaded {
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
                                received: .now, // TODO: fix
                                socket: ConcreteSocket.init(fileDescriptor: client),
                                logger: logger
                            )
                        } catch {
                            logger.warning(Logger.Message(stringLiteral: "Encountered error while processing client: \(error)"))
                        }
                    }
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