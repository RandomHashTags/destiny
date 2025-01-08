//
//  Epoll.swift
//
//
//  Created by Evan Anderson on 1/7/25.
//

#if os(Linux)
import CEpoll
import Glibc
import Logging
import ServiceLifecycle

extension Server where ClientSocket : ~Copyable {
    @inlinable
    func processClientsEpoll(serverFD: Int32, acceptClient: (Int32) throws -> Int32) async {
        setNonBlocking(socket: serverFD)
        
        let maxEvents:Int = 64
        let epollFD:Int32 = epoll_create1(0)
        guard epollFD != -1 else {
            fatalError("epoll;broken1")
        }
        var event:epoll_event = epoll_event()
        event.events = EPOLLIN.rawValue
        event.data.fd = serverFD

        let result:Int32 = epoll_ctl(epollFD, EPOLL_CTL_ADD, serverFD, &event)
        guard result != -1 else {
            fatalError("epoll;broken2")
        }

        var events:[epoll_event] = .init(repeating: epoll_event(), count: maxEvents)
        while !Task.isCancelled && !Task.isShuttingDownGracefully {
            let count:Int32 = epoll_wait(epollFD, &events, Int32(maxEvents), -1)
            guard count != -1 else {
                fatalError("epoll;broken3")
            }

            for i in 0..<count {
                let event:epoll_event = events[Int(i)]
                var client:Int32 = event.data.fd
                if client == serverFD {
                    do {
                        client = try acceptClient(serverFD)
                        setNonBlocking(socket: client)
                        var clientEvent:epoll_event = .init()
                        clientEvent.events = EPOLLIN.rawValue
                        clientEvent.data.fd = client
                        epoll_ctl(epollFD, EPOLL_CTL_ADD, client, &clientEvent)
                    } catch {
                        print("epoll;broken4")
                    }
                } else if event.events & EPOLLIN.rawValue != 0 {
                    epoll_ctl(epollFD, EPOLL_CTL_DEL, client, nil)
                    Task {
                        do {
                            try await ClientProcessing.process(
                                client: client,
                                socket: ClientSocket(fileDescriptor: client),
                                logger: self.logger,
                                router: self.router
                            )
                        } catch {
                            self.logger.warning(Logger.Message(stringLiteral: "[Epoll] Encountered error processing client: \(error)"))
                        }
                    }
                }
            }
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

#endif