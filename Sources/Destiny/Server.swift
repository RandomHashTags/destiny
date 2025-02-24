//
//  Server.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

#if canImport(Foundation)
import Foundation
#endif

import ArgumentParser
import Logging
import ServiceLifecycle

// MARK: Server
/// A default `ServerProtocol` implementation.
public final class Server<ClientSocket : SocketProtocol & ~Copyable> : ServerProtocol {
    public let address:String?
    public let port:UInt16
    /// The maximum amount of pending connections the Server will queue.
    /// This value is capped at the system's limit.
    public let backlog:Int32
    public let router:RouterProtocol
    public let logger:Logger
    public let commands:[ParsableCommand.Type] // TODO: fix (wait for swift-argument-parser to update to enable official Swift 6 support)
    public let onLoad:(@Sendable () -> Void)?
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
        router: RouterProtocol,
        logger: Logger,
        commands: [ParsableCommand.Type] = [
            StopCommand.self
        ],
        onLoad: (@Sendable () -> Void)? = nil,
        onShutdown: (@Sendable () -> Void)? = nil
    ) throws {
        var address:String? = address
        var port:UInt16 = port
        var backlog:Int32 = backlog

        let parsed:BootCommands = try BootCommands.parse()
        address = parsed.hostname ?? address
        port = parsed.port ?? port
        backlog = parsed.backlog ?? backlog
        reuseAddress = parsed.reuseaddress
        reusePort = parsed.reuseport
        noTCPDelay = parsed.tcpnodelay

        self.address = address
        self.port = port
        self.backlog = min(SOMAXCONN, backlog)
        self.router = router
        self.logger = logger
        self.commands = commands
        self.onLoad = onLoad
        self.onShutdown = onShutdown
    }
    
    // MARK: Run
    public func run() async throws {
        let serverFD1:Int32 = try bind()
        //let serverFD2:Int32 = try bind()
        //let serverFD3:Int32 = try bind()
        Task {
            await processCommand()
        }
        onLoad?()
        for index in router.dynamicMiddleware.indices {
            router.dynamicMiddleware[index].load()
        }
        await withTaskCancellationOrGracefulShutdownHandler {
            await processClients(serverFD: serverFD1)
            //processClients(serverFD: serverFD2)
            //processClients(serverFD: serverFD3)
            /*let duration:Duration = .seconds(5)
            while !Task.isCancelled && !Task.isShuttingDownGracefully {
                do {
                    try await Task.sleep(for: duration)
                } catch {
                }
            }*/
        } onCancelOrGracefulShutdown: {
            self.onShutdown?()
            close(serverFD1)
            //close(serverFD2)
            //close(serverFD3)
        }
    }

    /// - Returns: The file descriptor of the server.
    func bind() throws -> Int32 {
        #if os(Linux)
        let serverFD:Int32 = socket(AF_INET6, Int32(SOCK_STREAM.rawValue), 0)
        #else
        let serverFD:Int32 = socket(AF_INET6, SOCK_STREAM, 0)
        #endif
        if serverFD == -1 {
            #if canImport(Foundation)
            throw ServerError.socketCreationFailed(cerror())
            #else
            throw ServerError.socketCreationFailed()
            #endif
        }
        self.serverFD = serverFD
        Socket.noSigPipe(fileDescriptor: serverFD)
        #if os(Linux)
        var addr:sockaddr_in6 = sockaddr_in6(
            sin6_family: sa_family_t(AF_INET6),
            sin6_port: port.bigEndian,
            sin6_flowinfo: 0,
            sin6_addr: in6addr_any,
            sin6_scope_id: 0
        )
        #else
        var addr:sockaddr_in6 = sockaddr_in6(
            sin6_len: UInt8(MemoryLayout<sockaddr_in>.stride),
            sin6_family: UInt8(AF_INET6),
            sin6_port: port.bigEndian,
            sin6_flowinfo: 0,
            sin6_addr: in6addr_any,
            sin6_scope_id: 0
        )
        #endif
        if let address:String = address {
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
            Glibc.bind(serverFD, UnsafePointer<sockaddr>(OpaquePointer($0)), socklen_t(MemoryLayout<sockaddr_in6>.size))
        }
        if binded == -1 {
            close(serverFD)
            #if canImport(Foundation)
            throw ServerError.bindFailed(cerror())
            #else
            throw ServerError.bindFailed()
            #endif
        }
        if listen(serverFD, backlog) == -1 {
            close(serverFD)
            #if canImport(Foundation)
            throw ServerError.listenFailed(cerror())
            #else
            throw ServerError.listenFailed()
            #endif
        }
        logger.notice(Logger.Message(stringLiteral: "Listening for clients on http://\(address ?? "localhost"):\(port) [backlog=\(backlog), serverFD=\(serverFD)]"))
        return serverFD
    }

    // MARK: Process commands
    private func readCommand() async -> String? {
        return await withCheckedContinuation { continuation in
            continuation.resume(returning: readLine())
        }
    }
    func processCommand() async {
        if let line:String = await readCommand() {
            let arguments:[Substring] = line.split(separator: " ")
            if let targetCMD:Substring = arguments.first {
                let targetCommand:String = String(targetCMD)
                for command in commands {
                    if targetCommand == command.configuration.commandName {
                        var value:ParsableCommand = command.init()
                        do {
                            if var asyncValue:AsyncParsableCommand = value as? AsyncParsableCommand {
                                try await asyncValue.run()
                            } else {
                                try value.run()
                            }
                        } catch {
                            self.logger.warning(Logger.Message(stringLiteral: "Encountered error while executing command \"\(targetCMD)\": \(error)"))
                        }
                        break
                    }
                }
            }
        }
        guard !Task.isCancelled && !Task.isShuttingDownGracefully else { return }
        Task {
            await processCommand()
        }
    }
}

// MARK: Process clients
extension Server where ClientSocket : ~Copyable {
    @inlinable
    func processClients(serverFD: Int32) async {
        //await processClientsOLD(serverFD: serverFD)

        let function:@Sendable (Int32) throws -> (Int32, ContinuousClock.Instant)? = noTCPDelay ? Self.acceptClientNoTCPDelay : Self.acceptClient
        //await processClientsPoll(serverFD: serverFD, acceptClient: function)
        await processClientsEpoll(serverFD: serverFD, threads: 1, acceptClient: function, router: router)
    }

    @inlinable
    func processClientsOLD(serverFD: Int32) async {
        let acceptClient:(Int32) throws -> (Int32, ContinuousClock.Instant)? = noTCPDelay ? Self.acceptClientNoTCPDelay : Self.acceptClient
        while !Task.isCancelled && !Task.isShuttingDownGracefully {
            await withTaskGroup(of: Void.self) { group in
                for _ in 0..<backlog {
                    group.addTask {
                        do {
                            guard let (client, instant):(Int32, ContinuousClock.Instant) = try acceptClient(serverFD) else { return }
                            try await ClientProcessing.process(
                                client: client,
                                received: instant,
                                socket: ClientSocket(fileDescriptor: client),
                                logger: self.logger,
                                router: self.router
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

// MARK: Accept client
extension Server where ClientSocket : ~Copyable {
    @inlinable
    static func acceptClient(server: Int32?) throws -> (fileDescriptor: Int32, instant: ContinuousClock.Instant)? {
        guard let serverFD:Int32 = server else { return nil }
        var addr:sockaddr_in = sockaddr_in(), len:socklen_t = socklen_t(MemoryLayout<sockaddr_in>.size)
        let client:Int32 = withUnsafeMutablePointer(to: &addr, { $0.withMemoryRebound(to: sockaddr.self, capacity: 1, { accept(serverFD, $0, &len) }) })
        //let client:Int32 = accept(serverFD, withUnsafeMutablePointer(to: &addr) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { $0 } }, &len)
        if client == -1 {
            if server == nil {
                return nil
            }
            #if canImport(Foundation)
            throw SocketError.acceptFailed(cerror())
            #else
            throw SocketError.acceptFailed()
            #endif
        }
        return (client, .now)
    }
    @inlinable
    static func acceptClientNoTCPDelay(server: Int32?) throws -> (fileDescriptor: Int32, instant: ContinuousClock.Instant)? {
        guard let serverFD:Int32 = server else { return nil }
        var addr:sockaddr_in = sockaddr_in(), len:socklen_t = socklen_t(MemoryLayout<sockaddr_in>.size)
        let client:Int32 = accept(serverFD, withUnsafeMutablePointer(to: &addr) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { $0 } }, &len)
        if client == -1 {
            if server == nil {
                return nil
            }
            #if canImport(Foundation)
            throw SocketError.acceptFailed(cerror())
            #else
            throw SocketError.acceptFailed()
            #endif
        }
        var d:Int32 = 1
        setsockopt(client, Int32(IPPROTO_TCP), TCP_NODELAY, &d, socklen_t(MemoryLayout<Int32>.size))
        return (client, .now)
    }
}

// MARK: ServerError
enum ServerError : Swift.Error {
    case socketCreationFailed(String = "")
    case bindFailed(String = "")
    case listenFailed(String = "")
}