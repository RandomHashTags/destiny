
#if CopyableHTTPServer

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Foundation)
import Foundation
#endif

import DestinyEmbedded

#if canImport(DestinyBlueprint)
import DestinyBlueprint
#endif

#if Logging
import Logging
#endif

// MARK: Server
/// Default HTTP Server implementation.
public final class HTTPServer<
        Router: HTTPRouterProtocol,
        ClientSocket: HTTPSocketProtocol & ~Copyable
    > {
    public let address:String?
    public let port:UInt16
    /// Maximum amount of pending connections the Server will queue.
    /// This value is capped at the system's limit.
    public let backlog:Int32
    public let router:Router

    #if Logging
    public let logger:Logger
    #endif

    /// Called when the server loads successfully, just before it accepts incoming network requests.
    public let onLoad:(@Sendable () -> Void)?

    /// Called when the server terminates.
    public let onShutdown:(@Sendable () -> Void)?

    @usableFromInline
    let flags:Flag.RawValue

    @usableFromInline
    nonisolated(unsafe) private(set) var serverFD:Int32? = nil

    // MARK: Init
    #if Logging
    public init(
        address: String? = nil,
        port: UInt16,
        backlog: Int32 = SOMAXCONN,
        reuseAddress: Bool = true,
        reusePort: Bool = true,
        noTCPDelay: Bool = true,
        router: Router,
        logger: Logger,
        onLoad: (@Sendable () -> Void)? = nil,
        onShutdown: (@Sendable () -> Void)? = nil
    ) {
        self.address = address
        self.port = port
        self.backlog = min(SOMAXCONN, backlog)
        flags = Flag.pack(noTCPDelay: noTCPDelay, reuseAddress: reuseAddress, reusePort: reusePort)
        self.router = router
        self.logger = logger
        self.onLoad = onLoad
        self.onShutdown = onShutdown
    }
    #else
    public init(
        address: String? = nil,
        port: UInt16,
        backlog: Int32 = SOMAXCONN,
        reuseAddress: Bool = true,
        reusePort: Bool = true,
        noTCPDelay: Bool = true,
        router: Router,
        onLoad: (@Sendable () -> Void)? = nil,
        onShutdown: (@Sendable () -> Void)? = nil
    ) {
        self.address = address
        self.port = port
        self.backlog = min(SOMAXCONN, backlog)
        flags = Flag.pack(noTCPDelay: noTCPDelay, reuseAddress: reuseAddress, reusePort: reusePort)
        self.router = router
        self.onLoad = onLoad
        self.onShutdown = onShutdown
    }
    #endif
    
    // MARK: Run
    public func run() async throws(ServiceError) {
        onLoad?()
        do throws(RouterError) {
            try router.load()
        } catch {
            throw .serverError(.routerError(error))
        }
        do throws(ServerError) {
            try await processClients()
        } catch {
            throw .serverError(error)
        }
    }

    public func shutdown() {
        self.onShutdown?()
        serverFD?.socketClose()
    }

    /// - Returns: The file descriptor of the created socket.
    func bindAndListen() throws(ServerError) -> Int32 {
        #if canImport(Glibc)
        let serverFD = socket(AF_INET6, Int32(SOCK_STREAM.rawValue), 0)
        #else
        let serverFD = socket(AF_INET6, Int32(SOCK_STREAM.rawValue), 0)
        #endif
        if serverFD == -1 {
            throw .socketCreationFailed(errno: cError())
        }
        self.serverFD = serverFD
        ClientSocket.noSigPipe(fileDescriptor: serverFD)
        #if canImport(Glibc)
        var addr = sockaddr_in6(
            sin6_family: sa_family_t(AF_INET6),
            sin6_port: port.bigEndian,
            sin6_flowinfo: 0,
            sin6_addr: in6addr_any,
            sin6_scope_id: 0
        )
        #else
        var addr = sockaddr_in6(
            sin6_len: UInt8(MemoryLayout<sockaddr_in>.stride),
            sin6_family: UInt8(AF_INET6),
            sin6_port: port.bigEndian,
            sin6_flowinfo: 0,
            sin6_addr: in6addr_any,
            sin6_scope_id: 0
        )
        #endif
        if let address {
            if address.withCString({ inet_pton(AF_INET6, $0, &addr.sin6_addr) }) == 1 {
            }
        }
        if reuseAddress {
            var r:Int32 = 1
            setsockopt(serverFD, SOL_SOCKET, SO_REUSEADDR, &r, socklen_t(MemoryLayout<Int32>.size))
        }
        #if canImport(Glibc)
        if reusePort {
            var r:Int32 = 1
            setsockopt(serverFD, SOL_SOCKET, SO_REUSEPORT, &r, socklen_t(MemoryLayout<Int32>.size))
        }
        #endif
        var binded:Int32 = -1
        binded = withUnsafePointer(to: &addr) {
            bind(serverFD, UnsafePointer<sockaddr>(OpaquePointer($0)), socklen_t(MemoryLayout<sockaddr_in6>.size))
        }
        if binded == -1 {
            serverFD.socketClose()
            throw .bindFailed(errno: cError())
        }
        if listen(serverFD, backlog) == -1 {
            serverFD.socketClose()
            throw .listenFailed(errno: cError())
        }
        setNonBlocking(socket: serverFD)

        #if Logging
        logger.info("Listening for clients on http://\(address ?? "localhost"):\(port) [backlog=\(backlog), serverFD=\(serverFD)]")
        #endif
        return serverFD
    }
}

// MARK: Flags
extension HTTPServer where ClientSocket: ~Copyable {
    @usableFromInline
    enum Flag: UInt8 {
        case noTCPDelay   = 1
        case reuseAddress = 2
        case reusePort    = 4

        #if Inlinable
        @inlinable
        #endif
        static func pack(
            noTCPDelay: Bool,
            reuseAddress: Bool,
            reusePort: Bool
        ) -> Flag.RawValue {
            return (noTCPDelay ? Flag.noTCPDelay.rawValue : 0)
                | (reuseAddress ? Flag.reuseAddress.rawValue : 0)
                | (reusePort ? Flag.reusePort.rawValue : 0)
        }
    }

    #if Inlinable
    @inlinable
    #endif
    func isFlag(_ flag: Flag) -> Bool {
        flags & flag.rawValue != 0
    }

    #if Inlinable
    @inlinable
    #endif
    public var noTCPDelay: Bool {
        isFlag(.noTCPDelay)
    }

    #if Inlinable
    @inlinable
    #endif
    public var reuseAddress: Bool {
        isFlag(.reuseAddress)
    }

    #if Inlinable
    @inlinable
    #endif
    public var reusePort: Bool {
        isFlag(.reusePort)
    }
}

// MARK: Process clients
extension HTTPServer where ClientSocket: ~Copyable {
    #if Inlinable
    @inlinable
    #endif
    func setNonBlocking(socket: Int32) {
        let flags = fcntl(socket, F_GETFL, 0)
        guard flags != -1 else {
            fatalError("HTTPServer;setNonBlocking;broken1")
        }
        let result = fcntl(socket, F_SETFL, flags | O_NONBLOCK)
        guard result != -1 else {
            fatalError("HTTPServer;setNonBlocking;broken2")
        }
    }

    #if Inlinable
    @inlinable
    #endif
    func processClients() async throws(ServerError) {
        #if Epoll
        let _:InlineArray<64, Bool>? = processClientsEpoll(port: port, router: router)
        #else
        let serverFD1 = try bindAndListen()
        await processClientsOLD(serverFD: serverFD)
        #endif
    }

    #if !Epoll && !Liburing
    #if Inlinable
    @inlinable
    #endif
    func processClientsOLD(serverFD: Int32) async {
        let acceptClient = acceptFunction(noTCPDelay: noTCPDelay)
        while !Task.isCancelled {
            await withTaskGroup(of: Void.self) { group in
                for _ in 0..<backlog {
                    group.addTask {
                        do throws(SocketError) {
                            guard let client = try acceptClient(serverFD) else { return }
                            let socket = ClientSocket(fileDescriptor: client)
                            self.router.handle(client: client, socket: socket, completionHandler: {
                                client.socketClose()
                            })
                        } catch {
                            #if Logging
                            self.logger.warning("\(#function);\(error)")
                            #endif
                        }
                    }
                }
                await group.waitForAll()
            }
        }
    }
    #endif
}

#if Epoll
// MARK: Epoll
extension HTTPServer where ClientSocket: ~Copyable {
    @discardableResult
    #if Inlinable
    @inlinable
    #endif
    func processClientsEpoll<let maxEvents: Int>(
        port: UInt16,
        router: Router
    ) -> InlineArray<maxEvents, Bool>? {
        do throws(EpollError) {
            var processor = try EpollWorker<maxEvents>.create(workerId: 0, backlog: backlog, port: port)
            processor.run(timeout: -1, handleClient: { client, handler in
                let socket = ClientSocket(fileDescriptor: client)
                router.handle(client: client, socket: socket, completionHandler: handler)
            })
            processor.shutdown()
        } catch {
            #if Logging
            logger.error("HTTPServer;\(#function);error=\(error)")
            #endif
        }
        return nil
    }
}
#endif

// MARK: Conformances
extension HTTPServer: HTTPServerProtocol {}
extension HTTPServer: SocketAcceptor {}

#endif