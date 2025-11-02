
#if Epoll

import CEpoll
import Glibc

#if Logging
import Logging
#endif

/// Native Swift support for Epoll.
public struct Epoll<let maxEvents: Int>: SocketProvider {
    public let fileDescriptor:Int32
    public let pipeFileDescriptors:(read: Int32, write: Int32)

    #if Logging
    public let logger:Logger
    #endif

    /// - Throws: `EpollError`
    public init(label: String) throws(EpollError) {
        fileDescriptor = epoll_create1(0)
        if fileDescriptor == -1 {
            throw .epollCreateFailed(errno: cError())
        }
        var pipeFileDescriptors:InlineArray<2, Int32> = [0, 0]
        var err:EpollError? = nil
        pipeFileDescriptors.mutableSpan.withUnsafeBufferPointer {
            guard let base = $0.baseAddress else {
                err = .custom("epollPipeFailed;baseAddress == nil")
                return
            }
            pipe(.init(mutating: base))
        }
        if let err {
            close(fileDescriptor)
            throw err
        }
        self.pipeFileDescriptors = (pipeFileDescriptors[unchecked: 0], pipeFileDescriptors[unchecked: 1])

        #if Logging
        logger = Logger(label: label)
        #endif

        setNonBlocking(socket: pipeFileDescriptors[unchecked: 0])
        setNonBlocking(socket: pipeFileDescriptors[unchecked: 1])

        //try add(client: serverFD, event: EPOLLIN.rawValue)
        try add(client: pipeFileDescriptors[unchecked: 0], events: EPOLLIN.rawValue)
        //setNonBlocking(socket: self.fileDescriptor)
    }

    /// Flags a file descriptor as non-blocking.
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

    /// Closes all file descriptors managed by epoll.
    public func closeAll() {
        close(pipeFileDescriptors.read)
        close(pipeFileDescriptors.write)
        close(fileDescriptor)
    }
}

// MARK: Add
extension Epoll {
    /// Adds a file descriptor to epoll.
    /// 
    /// - Throws: `EpollError`
    public func add(client: Int32, events: UInt32) throws(EpollError) {
        var e = epoll_event()
        e.events = events
        e.data.fd = client
        if epoll_ctl(fileDescriptor, EPOLL_CTL_ADD, client, &e) == -1 {
            throw .epollCtlFailed(errno: cError())
        }
        #if DEBUG && Logging
        logger.info("EPOLL_CTL_ADD \(client): success (events=\(events))")
        #endif
    }
}

// MARK: Mod
extension Epoll {
    /// Modifies a file descriptor from epoll.
    /// 
    /// - Throws: `EpollError`
    public func mod(fd: Int32, events: UInt32) throws(EpollError) {
        var ev = epoll_event()
        ev.events = events
        ev.data.fd = fd
        if epoll_ctl(fileDescriptor, EPOLL_CTL_MOD, fd, &ev) == -1 {
            throw .epollCtlFailed(errno: cError())
        }
        #if DEBUG && Logging
        logger.info("EPOLL_CTL_MOD \(fd): success")
        #endif
    }
}

// MARK: Remove
extension Epoll {
    /// Deletes a file descriptor from epoll.
    /// 
    /// - Throws: `EpollError`
    public func remove(client: Int32) throws(EpollError) {
        if epoll_ctl(fileDescriptor, EPOLL_CTL_DEL, client, nil) == -1 {
            throw .epollCtlFailed(errno: cError())
        }
        #if DEBUG && Logging
        logger.info("EPOLL_CTL_DEL \(client): success")
        #endif
    }
}

// MARK: Rearm
extension Epoll {
    public func rearm(fd: Int32) {
        var ev = epoll_event()
        ev.events = UInt32(EPOLLIN.rawValue | EPOLLET.rawValue | EPOLLONESHOT.rawValue)
        ev.data.fd = fd
        epoll_ctl(fileDescriptor, EPOLL_CTL_MOD, fd, &ev)
        #if DEBUG && Logging
        logger.info("rearm \(fd): success")
        #endif
    }
}

// MARK: Wait
extension Epoll {
    /// Calls `epoll_pwait`.
    /// 
    /// - Returns: Number of loaded clients. Guaranteed to be greater than -1.
    /// - Throws: `EpollError`
    public func wait(
        timeout: Int32 = -1,
        events: inout MutableSpan<epoll_event>
    ) throws(EpollError) -> Int32 {
        var err:EpollError? = nil
        var loadedClients:Int32 = 0
        events.withUnsafeMutableBufferPointer { buffer in
            guard let base = buffer.baseAddress else {
                err = .custom("waitFailed;events.baseAddress == nil")
                return
            }
            #if DEBUG && Logging
            logger.info("calling epoll_pwait with timeout: \(timeout)")
            #endif

            loadedClients = epoll_pwait(fileDescriptor, base, Int32(maxEvents), timeout, nil)
        }
        if let err {
            throw err
        }
        #if DEBUG && Logging
        logger.info("epoll_pwait returning \(loadedClients)")
        #endif
        if loadedClients <= -1 {
            throw .negativeLoadedClients
        }
        return loadedClients
    }
}

#endif