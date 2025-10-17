
import SwiftSyntax

struct CompiledHTTPServer {
    var noncopyable = true
    var logging = true

    var address:String? = nil

    /// Underlying type should be `UInt16`.
    var port = "8080"

    /// Maximum amount of pending connections the Server will queue.
    /// This value is capped at the system's limit.
    /// 
    /// Underlying type should be `Int32`.
    var backlog = "SOMAXCONN"

    var routerType = "Router"

    var reuseAddress = true
    var reusePort = true
    var noTCPDelay = true

    /// Underlying type should be `Int`.
    var maxEpollEvents = "64"

    var socketType = "DestinyDefaults.HTTPSocket"

    /// Called when the server loads successfully, just before it accepts incoming network requests.
    var onLoad:String? = nil

    /// Called when the server terminates.
    var onShutdown:String? = nil
}

// MARK: Build
extension CompiledHTTPServer {
    func build(name: TokenSyntax) -> StructDeclSyntax {
        var members = MemberBlockItemListSyntax()
        members.append(routerDecl())
        if logging {
            members.append(loggerDecl())
        }
        members.append(runDecl())
        members.append(shutdownDecl())
        members.append(noTCPDelayDecl())
        members.append(reuseAddressDecl())
        members.append(reusePortDecl())
        members.append(bindAndListenDecl())
        members.append(setNonBlockingDecl())
        members.append(processClientsDecl())
        members.append(acceptClientDecl())
        members.append(processClientsOLDDecl())
        members.append(epollDecl())
        return StructDeclSyntax(
            modifiers: [.init(name: .keyword(.package))],
            name: name,
            inheritanceClause: .init(inheritedTypes: [
                .init(type: TypeSyntax("Sendable"), trailingComma: .commaToken()),
                .init(type: TypeSyntax("\(raw: noncopyable ? "~" : "")Copyable"))
            ]),
            memberBlock: .init(members: members)
        )
    }
}

// MARK: Router
extension CompiledHTTPServer {
    private func routerDecl() -> VariableDeclSyntax {
        return .init(
            .let,
            name: "router",
            type: TypeAnnotationSyntax(type: TypeSyntax("\(raw: routerType)"))
        )
    }
}

// MARK: Logger
extension CompiledHTTPServer {
    private func loggerDecl() -> VariableDeclSyntax {
        return .init(
            .let,
            name: "logger",
            type: TypeAnnotationSyntax(
                type: TypeSyntax("Logger")
            )
        )
    }
}

// MARK: Run
extension CompiledHTTPServer {
    private func runDecl() -> FunctionDeclSyntax {
        return .init(
            name: "run",
            signature: .init(
                parameterClause: .init(parameters: []),
                effectSpecifiers: .init(
                    asyncSpecifier: .keyword(.async),
                    throwsClause: .init(
                        throwsSpecifier: .keyword(.throws),
                        leftParen: .leftParenToken(),
                        type: TypeSyntax("ServiceError"),
                        rightParen: .rightParenToken()
                    )
                )
            ),
            body: .init(statements: .init(stringLiteral: """
            \(onLoad ?? "")
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
            """))
        )
    }
}

// MARK: Shutdown
extension CompiledHTTPServer {
    private func shutdownDecl() -> FunctionDeclSyntax {
        return .init(
            name: "shutdown",
            signature: .init(parameterClause: .init(parameters: [])),
            body: .init(statements: .init(stringLiteral: """
            \(onShutdown ?? "")
            //serverFD?.socketClose() // TODO: fix?
            """))
        )
    }
}

// MARK: Flags
extension CompiledHTTPServer {
    private func noTCPDelayDecl() -> VariableDeclSyntax {
        return .init(
            .var,
            name: "noTCPDelay",
            type: TypeAnnotationSyntax(type: TypeSyntax("Bool")),
            accessorBlock: .init(accessors: .getter(.init(stringLiteral: "\(noTCPDelay)")))
        )
    }
    private func reuseAddressDecl() -> VariableDeclSyntax {
        return .init(
            .var,
            name: "reuseAddress",
            type: TypeAnnotationSyntax(type: TypeSyntax("Bool")),
            accessorBlock: .init(accessors: .getter(.init(stringLiteral: "\(reuseAddress)")))
        )
    }
    private func reusePortDecl() -> VariableDeclSyntax {
        return .init(
            .var,
            name: "reusePort",
            type: TypeAnnotationSyntax(type: TypeSyntax("Bool")),
            accessorBlock: .init(accessors: .getter(.init(stringLiteral: "\(reusePort)")))
        )
    }
}

// MARK: Bind and listen
extension CompiledHTTPServer {
    private func bindAndListenDecl() -> FunctionDeclSyntax {
        let addressLogic:String
        if let address {
            addressLogic = """
            // set address
            if \(address).withCString({ inet_pton(AF_INET6, $0, &addr.sin6_addr) }) == 1 {
            }
            """
        } else {
            addressLogic = ""
        }

        let reuseAddressLogic:String
        if reuseAddress {
            reuseAddressLogic = """
            // reuse address
            var reuseAddressValue:Int32 = 1
            setsockopt(serverFD, SOL_SOCKET, SO_REUSEADDR, &reuseAddressValue, socklen_t(MemoryLayout<Int32>.size))
            """
        } else {
            reuseAddressLogic = ""
        }

        let reusePortLogic:String
        if reusePort {
            reusePortLogic = """
            #if canImport(Glibc)
            // reuse port
            var reusePortValue:Int32 = 1
            setsockopt(serverFD, SOL_SOCKET, SO_REUSEPORT, &reusePortValue, socklen_t(MemoryLayout<Int32>.size))
            #endif
            """
        } else {
            reusePortLogic = ""
        }

        let logInfo:String
        if logging {
            logInfo = "logger.info(\"Listening for clients on http://\(address ?? "localhost"):\(port) [backlog=\(backlog), serverFD=\\(serverFD)]\")"
        } else {
            logInfo = ""
        }
        return .init(
            leadingTrivia: "/// - Returns: The file descriptor of the created socket.\n",
            name: "bindAndListen",
            signature: .init(
                parameterClause: .init(parameters: []),
                effectSpecifiers: .init(
                    throwsClause: .init(
                        throwsSpecifier: .keyword(.throws),
                        leftParen: .leftParenToken(),
                        type: TypeSyntax("ServerError"),
                        rightParen: .rightParenToken()
                    )
                ),
                returnClause: .init(type: TypeSyntax("Int32"))
            ),
            body: .init(statements: .init(stringLiteral: """
            #if canImport(Glibc)
            let serverFD = socket(AF_INET6, Int32(SOCK_STREAM.rawValue), 0)
            #else
            let serverFD = socket(AF_INET6, Int32(SOCK_STREAM.rawValue), 0)
            #endif
            if serverFD == -1 {
                throw .socketCreationFailed(errno: cError())
            }
            \(socketType).noSigPipe(fileDescriptor: serverFD)
            #if canImport(Glibc)
            var addr = sockaddr_in6(
                sin6_family: sa_family_t(AF_INET6),
                sin6_port: UInt16(\(port)).bigEndian,
                sin6_flowinfo: 0,
                sin6_addr: in6addr_any,
                sin6_scope_id: 0
            )
            #else
            var addr = sockaddr_in6(
                sin6_len: UInt8(MemoryLayout<sockaddr_in>.stride),
                sin6_family: UInt8(AF_INET6),
                sin6_port: UInt16(\(port)).bigEndian,
                sin6_flowinfo: 0,
                sin6_addr: in6addr_any,
                sin6_scope_id: 0
            )
            #endif
            \(addressLogic)
            \(reuseAddressLogic)
            \(reusePortLogic)
            var binded:Int32 = -1
            binded = withUnsafePointer(to: &addr) {
                bind(serverFD, UnsafePointer<sockaddr>(OpaquePointer($0)), socklen_t(MemoryLayout<sockaddr_in6>.size))
            }
            if binded == -1 {
                serverFD.socketClose()
                throw .bindFailed(errno: cError())
            }
            if listen(serverFD, \(backlog)) == -1 {
                serverFD.socketClose()
                throw .listenFailed(errno: cError())
            }
            setNonBlocking(socket: serverFD)

            \(logInfo)

            return serverFD
            """))
        )
    }
}

// MARK: Set non-blocking
extension CompiledHTTPServer {
    private func setNonBlockingDecl() -> FunctionDeclSyntax {
        return .init(
            leadingTrivia: "\(inlinableAnnotation)\n",
            name: "setNonBlocking",
            signature: .init(
                parameterClause: .init(parameters: [
                    .init(firstName: "socket", type: TypeSyntax("Int32"))
                ])
            ),
            body: .init(statements: .init(stringLiteral: """
            let flags = fcntl(socket, F_GETFL, 0)
            guard flags != -1 else {
                fatalError("CompiledHTTPServer;setNonBlocking;broken1")
            }
            let result = fcntl(socket, F_SETFL, flags | O_NONBLOCK)
            guard result != -1 else {
                fatalError("CompiledHTTPServer;setNonBlocking;broken2")
            }
            """))
        )
    }
}

// MARK: Process clients
extension CompiledHTTPServer {
    private func processClientsDecl() -> FunctionDeclSyntax {
        return .init(
            leadingTrivia: "\(inlinableAnnotation)\n",
            name: "processClients",
            signature: .init(
                parameterClause: .init(parameters: []),
                effectSpecifiers: .init(
                    asyncSpecifier: .keyword(.async),
                    throwsClause: .init(
                        throwsSpecifier: .keyword(.throws),
                        leftParen: .leftParenToken(),
                        type: TypeSyntax("ServerError"),
                        rightParen: .rightParenToken()
                    )
                )
            ),
            body: .init(statements: .init(stringLiteral: """
            #if Epoll
            processClientsEpoll()
            #else
            let serverFD1 = try bindAndListen()
            await processClientsOLD(serverFD: serverFD1)
            #endif
            """))
        )
    }
}

// MARK: Accept function
extension CompiledHTTPServer {
    private func acceptClientDecl() -> FunctionDeclSyntax {
        let finalLogic:String
        if noTCPDelay {
            finalLogic = """
            var d:Int32 = 1
            setsockopt(client, Int32(IPPROTO_TCP), TCP_NODELAY, &d, socklen_t(MemoryLayout<Int32>.size))
            """
        } else {
            finalLogic = ""
        }
        return .init(
            leadingTrivia: "\(inlinableAnnotation)\n",
            modifiers: [.init(name: .keyword(.static))],
            name: "acceptClient",
            signature: .init(
                parameterClause: .init(parameters: [
                    .init(firstName: "_", secondName: "server", type: TypeSyntax("Int32?"))
                ]),
                effectSpecifiers: .init(
                    throwsClause: .init(
                        throwsSpecifier: .keyword(.throws),
                        leftParen: .leftParenToken(),
                        type: TypeSyntax("SocketError"),
                        rightParen: .rightParenToken()
                    ),
                ),
                returnClause: .init(type: TypeSyntax("Int32?"))
            ),
            body: .init(statements: .init(stringLiteral: """
            guard let serverFD = server else { return nil }
            var addr = sockaddr_in(), len = socklen_t(MemoryLayout<sockaddr_in>.size)
            let client = accept(serverFD, withUnsafeMutablePointer(to: &addr) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { $0 } }, &len)
            if client == -1 {
                if server == nil {
                    return nil
                }
                throw .acceptFailed(errno: cError())
            }
            \(finalLogic)
            return client
            """))
        )
    }
}

// MARK: Process clients old
extension CompiledHTTPServer {
    private func processClientsOLDDecl() -> FunctionDeclSyntax {
        let logWarning:String
        if logging {
            logWarning = "self.logger.warning(\"\\(#function);\\(error)\")"
        } else {
            logWarning = ""
        }
        return .init(
            leadingTrivia: "#if !Epoll && !Liburing\n",
            name: "processClientsOLD",
            signature: .init(
                parameterClause: .init(parameters: [
                    .init(firstName: "serverFD", type: TypeSyntax("Int32"))
                ]),
                effectSpecifiers: .init(
                    asyncSpecifier: .keyword(.async)
                )
            ),
            body: .init(statements: .init(stringLiteral: """
            while !Task.isCancelled {
                await withTaskGroup(of: Void.self) { group in
                    for _ in 0..<\(backlog) {
                        group.addTask {
                            do throws(SocketError) {
                                guard let client = try Self.acceptClient(serverFD) else { return }
                                let socket = \(socketType)(fileDescriptor: client)
                                self.router.handle(client: client, socket: socket, completionHandler: {
                                    client.socketClose()
                                })
                            } catch {
                                \(logWarning)
                            }
                        }
                    }
                    await group.waitForAll()
                }
            }
            """),
            trailingTrivia: "\n#endif")
        )
    }
}

// MARK: Epoll
extension CompiledHTTPServer {
    private func epollDecl() -> FunctionDeclSyntax {
        let logError:String
        if logging {
            logError = "logger.error(\"CompiledHTTPServer;\\(#function);error=\\(error)\")"
        } else {
            logError = ""
        }
        return .init(
            leadingTrivia: "#if Epoll\n\(inlinableAnnotation)\n",
            name: "processClientsEpoll",
            signature: .init(
                parameterClause: .init(parameters: [])
            ),
            body: .init(statements: .init(stringLiteral: """
            do throws(EpollError) {
                var processor = try EpollWorker<\(maxEpollEvents)>.create(workerId: 0, backlog: \(backlog), port: \(port))
                processor.run(timeout: -1, handleClient: { client, handler in
                    let socket = \(socketType)(fileDescriptor: client)
                    router.handle(client: client, socket: socket, completionHandler: handler)
                })
                processor.shutdown()
            } catch {
                \(logError)
            }
            """),
            trailingTrivia: "\n#endif")
        )
    }
}