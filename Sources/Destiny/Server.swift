//
//  Server.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import ArgumentParser
import DestinyBlueprint
import Foundation
import Logging
import ServiceLifecycle

// MARK: Server
/// A default `HTTPServerProtocol` implementation.
public final class Server<ClientSocket : SocketProtocol & ~Copyable> : HTTPServerProtocol {
    public let address:String?
    public let port:UInt16
    /// The maximum amount of pending connections the Server will queue.
    /// This value is capped at the system's limit.
    public let backlog:Int32
    public let router:any RouterProtocol
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
        router: any RouterProtocol,
        logger: Logger,
        commands: [ParsableCommand.Type] = [
            StopCommand.self
        ],
        onLoad: (@Sendable () -> Void)? = nil,
        onShutdown: (@Sendable () -> Void)? = nil
    ) throws {
        var address = address
        var port = port
        var backlog = backlog

        let parsed = try BootCommands.parse()
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
        let serverFD1 = try bindAndListen()
        //let serverFD2 = try bindAndListen()
        //let serverFD3 = try bindAndListen()
        Task {
            await processCommand()
        }
        onLoad?()
        router.loadDynamicMiddleware()
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

// MARK: Process commands
extension Server where ClientSocket : ~Copyable {
    private func readCommand() async -> String? {
        return await withCheckedContinuation { $0.resume(returning: readLine()) }
    }
    func processCommand() async {
        if let line = await readCommand() {
            let arguments = line.split(separator: " ")
            if let targetCMD = arguments.first {
                let targetCommand = String(targetCMD)
                for command in commands {
                    if targetCommand == command.configuration.commandName {
                        var value = command.init()
                        do {
                            if var asyncValue = value as? AsyncParsableCommand {
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
        let function = noTCPDelay ? Self.acceptClientNoTCPDelay : Self.acceptClient

        #if os(Linux)
        await processClientsEpoll(serverFD: serverFD, threads: 1, maxEvents: 64, acceptClient: function, router: router)
        #else
        await processClientsOLD(serverFD: serverFD, acceptClient: function)
        #endif
    }

    @inlinable
    func processClientsOLD(serverFD: Int32, acceptClient: @escaping @Sendable (Int32) throws -> (Int32, ContinuousClock.Instant)?) async {
        while !Task.isCancelled && !Task.isShuttingDownGracefully {
            await withTaskGroup(of: Void.self) { group in
                for _ in 0..<backlog {
                    group.addTask {
                        do {
                            guard let (client, instant) = try acceptClient(serverFD) else { return }
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
    @Sendable
    static func acceptClient(server: Int32?) throws -> (fileDescriptor: Int32, instant: ContinuousClock.Instant)? {
        guard let serverFD = server else { return nil }
        var addr = sockaddr_in(), len = socklen_t(MemoryLayout<sockaddr_in>.size)
        let client = withUnsafeMutablePointer(to: &addr, { $0.withMemoryRebound(to: sockaddr.self, capacity: 1, { accept(serverFD, $0, &len) }) })
        if client == -1 {
            if server == nil {
                return nil
            }
            throw SocketError.acceptFailed()
        }
        return (client, .now)
    }
    @inlinable
    @Sendable
    static func acceptClientNoTCPDelay(server: Int32?) throws -> (fileDescriptor: Int32, instant: ContinuousClock.Instant)? {
        guard let serverFD = server else { return nil }
        var addr = sockaddr_in(), len = socklen_t(MemoryLayout<sockaddr_in>.size)
        let client = accept(serverFD, withUnsafeMutablePointer(to: &addr) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { $0 } }, &len)
        if client == -1 {
            if server == nil {
                return nil
            }
            throw SocketError.acceptFailed()
        }
        var d:Int32 = 1
        setsockopt(client, Int32(IPPROTO_TCP), TCP_NODELAY, &d, socklen_t(MemoryLayout<Int32>.size))
        return (client, .now)
    }
}