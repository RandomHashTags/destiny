
import DestinyBlueprint
import Foundation
import Logging

// MARK: Server
/// A default `HTTPServerProtocol` implementation.
public final class Server<Router: HTTPRouterProtocol, ClientSocket: HTTPSocketProtocol & ~Copyable>: HTTPServerProtocol, SocketAcceptor {
    public let address:String?
    public let port:UInt16
    /// The maximum amount of pending connections the Server will queue.
    /// This value is capped at the system's limit.
    public let backlog:Int32
    public var router:Router
    public let logger:Logger

    /// Called when the server loads successfully, just before it accepts incoming network requests.
    public let onLoad:(@Sendable () -> Void)?

    /// Called when the server terminates.
    public let onShutdown:(@Sendable () -> Void)?

    public let reuseAddress:Bool
    public let reusePort:Bool
    public let noTCPDelay:Bool

    @usableFromInline
    private(set) var serverFD:Int32? = nil

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
    ) throws {
        self.address = address
        self.port = port
        self.backlog = min(SOMAXCONN, backlog)
        self.reuseAddress = reuseAddress
        self.reusePort = reusePort
        self.noTCPDelay = noTCPDelay
        self.router = router
        self.logger = logger
        self.onLoad = onLoad
        self.onShutdown = onShutdown
    }
    
    // MARK: Run
    public func run() async throws {
        let serverFD1 = try bindAndListen()
        //let serverFD2 = try bindAndListen()
        //let serverFD3 = try bindAndListen()
        onLoad?()
        router.loadDynamicMiddleware()
        await processClients(serverFD: serverFD1)
    }

    public func shutdown() async throws {
        self.onShutdown?()
        if let serverFD {
            close(serverFD)
        }
    }

    /// - Returns: The file descriptor of the created socket.
    func bindAndListen() throws -> Int32 {
        #if os(Linux)
        let serverFD = socket(AF_INET6, Int32(SOCK_STREAM.rawValue), 0)
        #else
        let serverFD = socket(AF_INET6, SOCK_STREAM, 0)
        #endif
        if serverFD == -1 {
            throw ServerError.socketCreationFailed()
        }
        self.serverFD = serverFD
        Socket.noSigPipe(fileDescriptor: serverFD)
        #if os(Linux)
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
        #if os(Linux)
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
            close(serverFD)
            throw ServerError.bindFailed()
        }
        if listen(serverFD, backlog) == -1 {
            close(serverFD)
            throw ServerError.listenFailed()
        }
        logger.notice(Logger.Message(stringLiteral: "Listening for clients on http://\(address ?? "localhost"):\(port) [backlog=\(backlog), serverFD=\(serverFD)]"))
        return serverFD
    }
}

// MARK: Process clients
extension Server where ClientSocket: ~Copyable {
    @inlinable
    func processClients(serverFD: Int32) async {
        #if os(Linux)
        let _:InlineArray<1, InlineArray<64, Bool>>? = await processClientsEpoll(serverFD: serverFD, router: router)
        #else
        await processClientsOLD(serverFD: serverFD)
        #endif
    }

    @inlinable
    func processClientsOLD(serverFD: Int32) async {
        let acceptClient = acceptFunction(noTCPDelay: noTCPDelay)
        while !Task.isCancelled {
            await withTaskGroup(of: Void.self) { group in
                for _ in 0..<backlog {
                    group.addTask {
                        do {
                            guard let (client, instant) = try acceptClient(serverFD) else { return }
                            try await self.router.process(
                                client: client,
                                received: instant,
                                socket: ClientSocket(fileDescriptor: client),
                                logger: self.logger
                            )
                        } catch {
                            self.logger.warning(Logger.Message(stringLiteral: "\(error)"))
                        }
                    }
                }
                await group.waitForAll()
            }
        }
    }
}