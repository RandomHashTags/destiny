//
//  Poll.swift
//
//
//  Created by Evan Anderson on 1/7/25.
//

import Logging
import ServiceLifecycle

#if canImport(Glibc)
import Glibc
#endif

extension Server where ClientSocket : ~Copyable {
    @inlinable
    func processClientsPoll(serverFD: Int32, acceptClient: (Int32) throws -> Int32) async {
        var clients:[pollfd] = [pollfd(fd: serverFD, events: Int16(POLLIN), revents: 0)]
        var completed:Set<Int32> = []
        completed.reserveCapacity(Int(backlog))
        while !Task.isCancelled && !Task.isShuttingDownGracefully {
            let result:Int32 = Glibc.poll(&clients, nfds_t(clients.count), -1)
            if result == -1 {
                fatalError("broken1")
            }
            if clients[0].revents & Int16(POLLIN) != 0 {
                do {
                    let client:Int32 = try acceptClient(serverFD)
                    clients.append(pollfd(fd: client, events: Int16(POLLIN), revents: 0))
                } catch {
                    self.logger.warning(Logger.Message(stringLiteral: "[Poll] Encountered error accepting client: \(error)"))
                }
            }
            for i in 1..<clients.count {
                let clientPoll:pollfd = clients[i]
                if clientPoll.revents & Int16(POLLIN) != 0 {
                    let client:Int32 = clientPoll.fd
                    completed.insert(client)
                    Task {
                        do {
                            try await ClientProcessing.process(
                                client: client,
                                received: .now, // TODO: fix
                                socket: ClientSocket(fileDescriptor: client),
                                logger: self.logger,
                                router: self.router
                            )
                        } catch {
                            self.logger.warning(Logger.Message(stringLiteral: "[Poll] Encountered error processing client: \(error)"))
                        }
                    }
                }
            }
            clients.removeAll { completed.contains($0.fd) }
            completed.removeAll(keepingCapacity: true)
        }
    }
}