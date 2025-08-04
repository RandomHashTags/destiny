
#if os(Linux)
import CEpoll
import DestinyBlueprint
import Glibc
import Logging

// MARK: EpollProcessor
public struct EpollProcessor<let threads: Int, let maxEvents: Int, ConcreteSocket: HTTPSocketProtocol & ~Copyable>: Sendable, ~Copyable {
    public let instances:InlineArray<threads, Epoll<maxEvents>>

    @inlinable
    public init(
        serverFD: Int32
    ) throws { // TODO: fix
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
    public func add(
        client: Int32,
        event: UInt32
    ) throws(EpollError) {
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
            do throws(EpollError) {
                let (loaded, clients) = try instance.wait(timeout: timeout, acceptClient: acceptClient)
                var i = 0
                while i < loaded {
                    let client = clients[i]
                    do throws(EpollError) {
                        try instance.remove(client: client)
                    } catch {
                        logger.warning("Encountered error while removing client: \(error)")
                    }
                    let socket = ConcreteSocket(fileDescriptor: client)
                    router.handle(client: client, socket: socket, logger: logger)
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
        do { // TODO: fix
            let processor = try EpollProcessor<threads, maxEvents, ClientSocket>.init(
                serverFD: serverFD
            )
            await processor.run(timeout: -1, router: router, noTCPDelay: noTCPDelay)
            for i in processor.instances.indices {
                processor.instances[i].closeFileDescriptor()
            }
        } catch {
            logger.error("epollProcessor;processClientsEpoll;broken;error=\(error)")
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