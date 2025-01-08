//
//  Epoll.swift
//
//
//  Created by Evan Anderson on 1/7/25.
//

#if os(Linux)
import CEpoll
import Foundation
import Glibc
import Logging
import ServiceLifecycle

extension Server where ClientSocket : ~Copyable {
    @inlinable
    func processClientsEpoll<C: SocketProtocol & ~Copyable>(
        serverFD: Int32,
        acceptClient: @escaping (Int32) throws -> Int32,
        router: RouterProtocol
    ) -> C? {
        setNonBlocking(socket: serverFD)
        let maxEvents:Int = 64
        do {
            let processor:EpollProcessor = try EpollProcessor(threads: 4, maxEvents: maxEvents)
            let _:C? = processor.beginAccepting(timeout: 1000, router: router, acceptClient: acceptClient)
        } catch {
            print("epoll;processClientsEpoll;broken")
        }
        return nil
    }

    @inlinable
    func setNonBlocking(socket: Int32) {
        let flags:Int32 = fcntl(socket, F_GETFL, 0)
        guard flags != -1 else {
            fatalError("epoll;setNonBlocking;broken1")
        }
        let result:Int32 = fcntl(socket, F_SETFL, flags | O_NONBLOCK)
        guard result != -1 else {
            fatalError("epoll;setNonBlocking;broken2")
        }
    }
}

final class Epoll {
    private let fileDescriptor:Int32
    private var events:[epoll_event]
    let logger:Logger

    init(thread: Int, maxEvents: Int) throws {
        fileDescriptor = epoll_create1(0)
        if fileDescriptor == -1 {
            throw EpollError.epollCreateFailed
        }
        events = .init(repeating: epoll_event(), count: maxEvents)
        logger = Logger(label: "destiny.epoll.thread\(thread)")
        setNonBlocking(socket: fileDescriptor)
    }

    func setNonBlocking(socket: Int32) {
        let flags:Int32 = fcntl(socket, F_GETFL, 0)
        guard flags != -1 else {
            fatalError("epoll;setNonBlocking;broken1")
        }
        let result:Int32 = fcntl(socket, F_SETFL, flags | O_NONBLOCK)
        guard result != -1 else {
            fatalError("epoll;setNonBlocking;broken2")
        }
    }

    func add(client: Int32, event: UInt32) throws {
        var e:epoll_event = .init()
        e.events = event
        e.data.fd = client
        if epoll_ctl(fileDescriptor, EPOLL_CTL_ADD, client, &e) == -1 {
            throw EpollError.epollCtlFailed
        }
    }

    func remove(client: Int32) throws {
        if epoll_ctl(fileDescriptor, EPOLL_CTL_DEL, client, nil) == -1 {
            throw EpollError.epollCtlFailed
        }
    }

    func wait(timeout: Int32 = -1, acceptClient: (Int32) throws -> Int32) throws -> [Int32] {
        let loadClients:Int32 = epoll_wait(fileDescriptor, &events, Int32(events.count), timeout)
        if loadClients == -1 {
            throw EpollError.waitFailed
        }
        logger.notice(Logger.Message(stringLiteral: "Epoll;wait;loadClients=\(loadClients)"))
        var clients:[Int32] = .init(repeating: -1, count: Int(loadClients))
        for i in 0..<loadClients {
            logger.notice(Logger.Message(stringLiteral: "Epoll;wait;i=\(i)"))
            let client:Int32 = try acceptClient(events[Int(i)].data.fd)
            do {
                try add(client: client, event: EPOLLIN.rawValue)
                setNonBlocking(socket: client)
                clients[Int(i)] = client
                logger.notice(Logger.Message(stringLiteral: "accepted client"))
            } catch {
                logger.warning(Logger.Message(stringLiteral: "Encountered error tring to add accepted client to epoll: \(error)"))
                close(client)
            }
        }
        return clients
    }

    func waitForEvents(timeout: Int32 = -1, acceptClient: @escaping (Int32) throws -> Int32) async throws -> [Int32] {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().async {
                do {
                    let clients:[Int32] = try self.wait(timeout: timeout, acceptClient: acceptClient)
                    continuation.resume(returning: clients)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    deinit {
        close(fileDescriptor)
    }
}

@usableFromInline
final class EpollProcessor {
    private let threads:Int
    private var instances:[Epoll]

    @usableFromInline
    init(threads: Int, maxEvents: Int = 64) throws {
        self.threads = threads
        var instances:[Epoll] = []
        instances.reserveCapacity(threads)
        for i in 0..<threads {
            instances.append(try Epoll(thread: i, maxEvents: maxEvents))
        }
        self.instances = instances
    }

    func add(client: Int32, event: UInt32) throws {
        let instance:Epoll = instances[Int(client) % threads]
        try instance.add(client: client, event: event)
    }

    @usableFromInline
    func beginAccepting<C: SocketProtocol & ~Copyable>(
        timeout: Int32 = 1000,
        router: RouterProtocol,
        acceptClient: @escaping (Int32) throws -> Int32
    ) -> C? {
        for instance in instances {
            DispatchQueue.global().async {
                let _:C? = self.process(instance, timeout: timeout, router: router, acceptClient: acceptClient)
            }
        }
        return nil
    }

    private func process<C: SocketProtocol & ~Copyable>(
        _ instance: Epoll,
        timeout: Int32,
        router: RouterProtocol,
        acceptClient: (Int32) throws -> Int32
    ) -> C? {
        while !Task.isCancelled && !Task.isShuttingDownGracefully {
            do {
                let clients:[Int32] = try instance.wait(timeout: timeout, acceptClient: acceptClient)
                for client in clients {
                    print("bro")
                    do {
                        try instance.remove(client: client)
                    } catch {
                        instance.logger.warning(Logger.Message(stringLiteral: "Encountered error while removing client: \(error)"))
                    }
                    print("client=\(client)")
                    Task {
                        do {
                            try await ClientProcessing.process(
                                client: client,
                                socket: C(fileDescriptor: client),
                                logger: instance.logger,
                                router: router
                            )
                        } catch {
                            instance.logger.warning(Logger.Message(stringLiteral: "Encountered error while processing client: \(error)"))
                        }
                    }
                }
            } catch {
                instance.logger.warning(Logger.Message(stringLiteral: "Encountered error while waiting for client: \(error)"))
            }
        }
        return nil
    }
}

enum EpollError : Error {
    case epollCreateFailed
    case epollCtlFailed
    case waitFailed
}

#endif