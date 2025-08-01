
#if os(Linux)
import DestinyBlueprint
import CEpoll
import Glibc
import Logging

// MARK: EpollProcessor
public struct EpollProcessor<let threads: Int, let maxEvents: Int, ConcreteSocket: HTTPSocketProtocol & ~Copyable>: Sendable, ~Copyable {
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
    public func run(
        timeout: Int32,
        router: some HTTPRouterProtocol,
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
            // TODO: fix? | doesn't cancel when graceful shutdown is triggered
        }
    }

    @inlinable
    public static func process(
        _ instance: inout Epoll<maxEvents>,
        timeout: Int32,
        router: some HTTPRouterProtocol,
        noTCPDelay: Bool
    ) async {
        let cancelPipeFD = instance.pipeFileDescriptors[1]
        let logger = instance.logger
        let acceptClient = instance.acceptFunction(noTCPDelay: noTCPDelay)
        while !Task.isCancelled {
            do {
                let (loaded, clients) = try instance.wait(timeout: timeout, acceptClient: acceptClient)
                var i = 0
                while i < loaded {
                    let client = clients[i]
                    do {
                        try instance.remove(client: client)
                    } catch {
                        logger.warning("Encountered error while removing client: \(error)")
                    }
                    Task {
                        do {
                            try await router.process(
                                client: client,
                                socket: ConcreteSocket.init(fileDescriptor: client),
                                logger: logger
                            )
                        } catch {
                            logger.warning("Encountered error while processing client: \(error)")
                        }
                    }
                    i += 1
                }
            } catch {
                logger.warning("Encountered error while waiting for client: \(error)")
            }
        }
        write(cancelPipeFD, "x", 1)
    }
}

// MARK: HTTPServer extension
extension HTTPServer where ClientSocket: ~Copyable {
    @discardableResult
    @inlinable
    func processClientsEpoll<let threads: Int, let maxEvents: Int>(
        serverFD: Int32,
        router: Router
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
            print("epollProcessor;processClientsEpoll;broken")
        }
        return nil
    }

    @inlinable
    func setNonBlocking(socket: Int32) {
        let flags = fcntl(socket, F_GETFL, 0)
        guard flags != -1 else {
            fatalError("epollProcessor;setNonBlocking;broken1")
        }
        let result = fcntl(socket, F_SETFL, flags | O_NONBLOCK)
        guard result != -1 else {
            fatalError("epollProcessor;setNonBlocking;broken2")
        }
    }
}

#endif