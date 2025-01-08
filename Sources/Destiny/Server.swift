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
    public let reuseAddress:Bool
    public let noTCPDelay:Bool
    public var router:RouterProtocol
    public let logger:Logger
    public let commands:[ParsableCommand.Type] // TODO: fix (wait for swift-argument-parser to update to enable official Swift 6 support)
    public let onLoad:(@Sendable () -> Void)?
    public let onShutdown:(@Sendable () -> Void)?

    public init(
        address: String? = nil,
        port: UInt16,
        backlog: Int32 = SOMAXCONN,
        router: consuming RouterProtocol,
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
        var binded:Int32 = -1
        binded = withUnsafePointer(to: &addr) {
            bind(serverFD, UnsafePointer<sockaddr>(OpaquePointer($0)), socklen_t(MemoryLayout<sockaddr_in6>.size))
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
        logger.notice(Logger.Message(stringLiteral: "Listening for clients on http://\(address ?? "localhost"):\(port) [backlog=\(backlog)]"))
        Task {
            await processCommand()
        }
        await withTaskCancellationOrGracefulShutdownHandler {
            onLoad?()
            for index in router.dynamicMiddleware.indices {
                router.dynamicMiddleware[index].load()
            }
            await processClients(serverFD: serverFD)
        } onCancelOrGracefulShutdown: {
            self.onShutdown?()
            close(serverFD)
        }
    }
    
    @inlinable
    func acceptClients(serverFD: Int32) -> AsyncStream<Int32> {
        let function:(Int32) throws -> Int32 = noTCPDelay ? Self.acceptClientNoTCPDelay : Self.acceptClient
        return AsyncStream<Int32> { continuation in
            while !Task.isCancelled && !Task.isShuttingDownGracefully {
                do {
                    let client:Int32 = try function(serverFD)
                    continuation.yield(client)
                } catch {
                    self.logger.warning(Logger.Message(stringLiteral: "Encountered error while trying to accept client: \(error)"))
                }
            }
            continuation.finish()
        }
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

    // MARK: Shutdown
    public func shutdown() async throws {
        // TODO: fix | doesn't shutdown properly (pending clients are blocking)
        logger.notice("Server shutting down...")
        try await gracefulShutdown()
        logger.notice("Server shutdown successfully")
    }
}

// MARK: Process clients
extension Server where ClientSocket : ~Copyable {
    @inlinable
    func processClients(serverFD: Int32) async {
        let function:(Int32) throws -> Int32 = noTCPDelay ? Self.acceptClientNoTCPDelay : Self.acceptClient
        await processClientsOLD(serverFD: serverFD, acceptClient: function)
        //await processClientsPoll(serverFD: serverFD, acceptClient: function)
        //await processClientsEpoll(serverFD: serverFD, acceptClient: function)
    }

    @inlinable
    func processClientsOLD(serverFD: Int32, acceptClient: @escaping (Int32) throws -> Int32) async {
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<backlog {
                group.addTask {
                    do {
                        let client:Int32 = try acceptClient(serverFD)
                        try await ClientProcessing.process(
                            client: client,
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

// MARK: Accept client
extension Server where ClientSocket : ~Copyable {
    @inlinable
    static func acceptClient(serverFD: Int32) throws -> Int32 {
        var addr:sockaddr_in = sockaddr_in(), len:socklen_t = socklen_t(MemoryLayout<sockaddr_in>.size)
        let client:Int32 = accept(serverFD, withUnsafeMutablePointer(to: &addr) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { $0 } }, &len)
        if client == -1 {
            #if canImport(Foundation)
            throw SocketError.acceptFailed(cerror())
            #else
            throw SocketError.acceptFailed()
            #endif
        }
        return client
    }
    @inlinable
    static func acceptClientNoTCPDelay(serverFD: Int32) throws -> Int32 {
        var addr:sockaddr_in = sockaddr_in(), len:socklen_t = socklen_t(MemoryLayout<sockaddr_in>.size)
        let client:Int32 = accept(serverFD, withUnsafeMutablePointer(to: &addr) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { $0 } }, &len)
        if client == -1 {
            #if canImport(Foundation)
            throw SocketError.acceptFailed(cerror())
            #else
            throw SocketError.acceptFailed()
            #endif
        }
        var d:Int32 = 1
        setsockopt(client, Int32(IPPROTO_TCP), TCP_NODELAY, &d, socklen_t(MemoryLayout<Int32>.size))
        return client
    }
}

// MARK: ServerError
enum ServerError : Swift.Error {
    case socketCreationFailed(String = "")
    case bindFailed(String = "")
    case listenFailed(String = "")
}