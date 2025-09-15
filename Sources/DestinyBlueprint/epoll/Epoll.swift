
#if os(Linux)

import CEpoll
import Glibc
import Logging

public struct Epoll<let maxEvents: Int>: Sendable {
    public let fileDescriptor:Int32
    public let pipeFileDescriptors:(read: Int32, write: Int32)
    public let logger:Logger

    public init(label: String) throws(EpollError) {
        fileDescriptor = epoll_create1(0)
        if fileDescriptor == -1 {
            throw .epollCreateFailed()
        }
        var pipeFileDescriptors:InlineArray<2, Int32> = [0, 0]
        var err:EpollError? = nil
        pipeFileDescriptors.mutableSpan.withUnsafeBufferPointer {
            guard let base = $0.baseAddress else {
                err = .epollPipeFailed()
                return
            }
            pipe(.init(mutating: base))
        }
        if let err {
            close(fileDescriptor)
            throw err
        }
        self.pipeFileDescriptors = (pipeFileDescriptors[0], pipeFileDescriptors[1])
        logger = Logger(label: label)
        setNonBlocking(socket: pipeFileDescriptors[0])
        setNonBlocking(socket: pipeFileDescriptors[1])

        //try add(client: serverFD, event: EPOLLIN.rawValue)
        try add(client: pipeFileDescriptors[0], events: EPOLLIN.rawValue)
        //setNonBlocking(socket: self.fileDescriptor)
    }

    #if Inlinable
    @inlinable
    #endif
    public func setNonBlocking(socket: Int32) {
        let flags = fcntl(socket, F_GETFL, 0)
        guard flags != -1 else {
            fatalError("epoll;setNonBlocking;broken1")
        }
        let result = fcntl(socket, F_SETFL, flags | O_NONBLOCK)
        guard result != -1 else {
            fatalError("epoll;setNonBlocking;broken2")
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public func add(client: Int32, events: UInt32) throws(EpollError) {
        var e = epoll_event()
        e.events = events
        e.data.fd = client
        if epoll_ctl(fileDescriptor, EPOLL_CTL_ADD, client, &e) == -1 {
            throw .epollCtlFailed()
        }
        #if DEBUG
        logger.info("EPOLL_CTL_ADD \(client): success")
        #endif
    }

    #if Inlinable
    @inlinable
    #endif
    public func mod(fd: Int32, events: UInt32) throws(EpollError) {
        var ev = epoll_event()
        ev.events = events
        ev.data.fd = fd
        if epoll_ctl(fileDescriptor, EPOLL_CTL_MOD, fd, &ev) == -1 {
            throw .epollCtlFailed()
        }
        #if DEBUG
        logger.info("EPOLL_CTL_MOD \(fd): success")
        #endif
    }

    #if Inlinable
    @inlinable
    #endif
    public func remove(client: Int32) throws(EpollError) {
        if epoll_ctl(fileDescriptor, EPOLL_CTL_DEL, client, nil) == -1 {
            throw .epollCtlFailed()
        }
        #if DEBUG
        logger.info("EPOLL_CTL_DEL \(client): success")
        #endif
    }

    #if Inlinable
    @inlinable
    #endif
    public func closeAll() {
        close(pipeFileDescriptors.read)
        close(pipeFileDescriptors.write)
        close(fileDescriptor)
    }
}

// MARK: Wait
extension Epoll {
    #if Inlinable
    @inlinable
    #endif
    public func wait(
        timeout: Int32 = -1,
        events: inout InlineArray<maxEvents, epoll_event>
    ) throws(EpollError) -> Int32 {
        var loadedClients:Int32 = -1
        var err:EpollError? = nil
        var mutableSpan = events.mutableSpan
        mutableSpan.withUnsafeMutableBufferPointer { p in
            do throws(EpollError) {
                loadedClients = try wait(events: p)
            } catch {
                err = error
            }
        }
        if let err {
            throw err
        }
        if loadedClients == -1 {
            throw .waitFailed()
        }
        return loadedClients
    }

    #if Inlinable
    @inlinable
    #endif
    public func wait(
        timeout: Int32 = -1,
        events: UnsafeMutableBufferPointer<epoll_event>
    ) throws(EpollError) -> Int32 {
        guard let base = events.baseAddress else { throw .waitFailed() }

        #if DEBUG
        logger.info("calling epoll_pwait with timeout: \(timeout)")
        #endif

        let loadedClients = epoll_pwait(fileDescriptor, base, Int32(maxEvents), timeout, nil)

        #if DEBUG
        logger.info("epoll_pwait returned \(loadedClients)")
        #endif
        if loadedClients == -1 {
            throw .waitFailed()
        }
        return loadedClients
    }
}

#endif