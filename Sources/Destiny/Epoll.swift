//
//  Epoll.swift
//
//
//  Created by Evan Anderson on 1/7/25.
//

#if os(Linux)
import CEpoll
import Dispatch
import Glibc
import Logging
import ServiceLifecycle

extension Server where ClientSocket : ~Copyable {
    @inlinable
    func processClientsEpoll(
        serverFD: Int32,
        threads: Int,
        maxEvents: Int,
        acceptClient: @escaping @Sendable (Int32) throws -> (Int32, ContinuousClock.Instant)?,
        router: RouterProtocol
    ) async {
        setNonBlocking(socket: serverFD)
        do {
            let processor:EpollProcessor = try EpollProcessor(
                serverFD: serverFD,
                threads: threads,
                maxEvents: maxEvents
            )
            try await processor.run(timeout: -1, router: router, acceptClient: acceptClient)
        } catch {
            print("epoll;processClientsEpoll;broken")
        }
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

extension Server where ClientSocket : ~Copyable {
    // MARK: Epoll
    final class Epoll : @unchecked Sendable {
        private let serverFD:Int32
        private let fileDescriptor:Int32
        private var events:[epoll_event]
        let logger:Logger

        init(serverFD: Int32, thread: Int, maxEvents: Int) throws {
            self.serverFD = serverFD
            fileDescriptor = epoll_create1(0)
            if fileDescriptor == -1 {
                throw EpollError.epollCreateFailed
            }
            events = .init(repeating: epoll_event(), count: maxEvents)
            logger = Logger(label: "destiny.epoll.\(serverFD).thread\(thread)")
            try add(client: serverFD, event: EPOLLIN.rawValue)
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

        func wait(timeout: Int32 = -1, acceptClient: (Int32) throws -> (Int32, ContinuousClock.Instant)?) throws -> [Int32] {
            let loadedClients:Int32 = epoll_wait(fileDescriptor, &events, Int32(events.count), timeout)
            if loadedClients == -1 {
                throw EpollError.waitFailed
            } else if loadedClients == 0 {
                return []
            }
            var clients:[Int32] = []
            for i in 0..<Int(loadedClients) {
                let event:epoll_event = events[i]
                if event.data.fd == serverFD {
                    do {
                        if let (client, instant):(Int32, ContinuousClock.Instant) = try acceptClient(serverFD) {
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
                    clients.append(event.data.fd)
                } else if event.events & EPOLLHUP.rawValue != 0 {
                    closeSocket(event.data.fd, name: "client disconnected")
                } else if event.events & EPOLLERR.rawValue != 0 {
                    closeSocket(event.data.fd, name: "client's socket errored")
                }
            }
            return clients
        }

        func closeSocket(_ socket: Int32, name: String) {
            let closed:Int32 = close(socket)
            if closed < 0 {
                logger.warning(Logger.Message(stringLiteral: "Failed to close socket with name: \(name) (errno=\(errno))"))
            }
        }

        deinit {
            closeSocket(fileDescriptor, name: "Epoll fileDescriptor")
        }
    }
}

extension Server where ClientSocket : ~Copyable {
    // MARK: EpollProcessor
    @usableFromInline
    final class EpollProcessor {
        private let threads:Int
        private let instances:[Epoll]

        @usableFromInline
        init(
            serverFD: Int32,
            threads: Int,
            maxEvents: Int = 64
        ) throws {
            self.threads = threads
            var instances:[Epoll] = []
            instances.reserveCapacity(threads)
            for i in 0..<threads {
                instances.append(try Epoll(serverFD: serverFD, thread: i, maxEvents: maxEvents))
            }
            self.instances = instances
        }

        func add(client: Int32, event: UInt32) throws {
            let instance:Epoll = instances[Int(client) % threads]
            try instance.add(client: client, event: event)
        }

        @usableFromInline
        func run(
            timeout: Int32,
            router: RouterProtocol,
            acceptClient: @escaping @Sendable (Int32) throws -> (Int32, ContinuousClock.Instant)?
        ) async throws {
            for instance in instances {
                DispatchQueue.global().async {
                    self.process(instance, timeout: timeout, router: router, acceptClient: acceptClient)
                }
            }
            while !Task.isCancelled && !Task.isShuttingDownGracefully {
                try await Task.sleep(for: .seconds(1))
            }
        }

        private func process(
            _ instance: Epoll,
            timeout: Int32,
            router: RouterProtocol,
            acceptClient: (Int32) throws -> (Int32, ContinuousClock.Instant)?
        ) {
            while !Task.isCancelled && !Task.isShuttingDownGracefully {
                do {
                    let clients:[Int32] = try instance.wait(timeout: timeout, acceptClient: acceptClient)
                    for client in clients {
                        do {
                            try instance.remove(client: client)
                        } catch {
                            instance.logger.warning(Logger.Message(stringLiteral: "Encountered error while removing client: \(error)"))
                        }
                        Task {
                            do {
                                try await ClientProcessing.process(
                                    client: client,
                                    received: .now, // TODO: fix
                                    socket: ClientSocket.init(fileDescriptor: client),
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
            print("EpollProcessor;process;finished")
            // TODO: fix (this doesn't get executed when the service is shutdown)
        }
    }

    // MARK: EpollError
    enum EpollError : Error {
        case epollCreateFailed
        case epollCtlFailed
        case waitFailed
    }
}

#endif