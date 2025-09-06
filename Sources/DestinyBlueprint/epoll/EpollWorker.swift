
#if os(Linux)
import CEpoll
import Glibc
import Logging

@_silgen_name("accept4")
#if Inlinable
@inlinable
#endif
func accept4_fd(
    _ sockfd: Int32,
    _ addr: UnsafeMutablePointer<sockaddr>?,
    _ addrlen: UnsafeMutablePointer<socklen_t>?,
    _ flags: Int32
) -> Int32

// MARK: EpollWorker
public struct EpollWorker<let maxEvents: Int>: Sendable, ~Copyable {
    @usableFromInline
    let listenFD:Int32

    @usableFromInline
    let ep:Epoll<maxEvents>

    @usableFromInline
    let logger:Logger

    @usableFromInline
    var running = true

    public static func create(
        workerId: Int,
        backlog: Int32,
        port: UInt16
    ) throws(EpollError) -> EpollWorker<maxEvents> {
        let logger = Logger(label: "epoll.worker.\(workerId)")
        let listenFD = Self.bindAndListen(port: port, backlog: backlog, logger: logger)
        let ep = try Epoll<maxEvents>.init(label: "epoll.worker.\(workerId)")

        // add listenFD with edge-triggered
        let flags = UInt32(EPOLLIN.rawValue) | UInt32(EPOLLET.rawValue)
        try ep.add(client: listenFD, events: flags)
        return .init(listenFD: listenFD, ep: ep, logger: logger)
    }

    public init(
        listenFD: Int32,
        ep: Epoll<maxEvents>,
        logger: Logger
    ) {
        self.listenFD = listenFD
        self.ep = ep
        self.logger = logger
    }

    deinit {
        ep.closeAll()
        close(listenFD)
    }

    // Pin this worker to a core to improve cache locality.
    #if Inlinable
    @inlinable
    #endif
    public func pinToCore(_ core: Int32) {
        /*var cpuset = cpu_set_t()
        CPU_ZERO(&cpuset)
        CPU_SET(UInt(core), &cpuset)
        let tid = pthread_self()
        pthread_setaffinity_np(tid, MemoryLayout<cpu_set_t>.size, &cpuset)*/
    }

    /// - Returns: accepted nonblocking file descriptor
    #if Inlinable
    @inlinable
    #endif
    func acceptNewConnection() -> Int32? {
        var addr = sockaddr_storage()
        var len = socklen_t(MemoryLayout<sockaddr_storage>.size)
        #if DEBUG
        logger.info("\(#function); calling accept4_fd")
        #endif
        let fd = withUnsafeMutablePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                accept4_fd(listenFD, $0, &len, Int32(SOCK_NONBLOCK.rawValue | SOCK_CLOEXEC.rawValue))
            }
        }
        if fd == -1 {
            if errno == EAGAIN || errno == EWOULDBLOCK {
                return nil
            }
            logger.warning("\(#function); accept4 failed (errno=\(errno))")
            return nil
        }
        #if DEBUG
        logger.info("\(#function); returned \(fd)")
        #endif
        return fd
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func shutdown() {
        running = false
        var c:UInt8 = 1
        _ = write(ep.pipeFileDescriptors.write, &c, 1)
    }
}

// MARK: Run
extension EpollWorker {
    /// - Parameters:
    ///   - pinToCore: Which core to run this on.
    ///   - timeout: Milliseconds to wait until we time-out.
    ///   - handleClient: Handle logic for a socket.
    #if Inlinable
    @inlinable
    #endif
    public mutating func run(
        pinToCore: Int32? = nil,
        timeout: Int32 = -1,
        handleClient: (_ socket: Int32, _ completionHandler: @Sendable @escaping () -> Void) -> Void
    ) throws(EpollError) {
        //if let c = pinToCore { pinToCore(c) }
        #if DEBUG
        logger.info("running with timeout: \(timeout)")
        #endif

        var events = InlineArray<maxEvents, epoll_event>(repeating: epoll_event())
        var mutableSpan = events.mutableSpan
        mutableSpan.withUnsafeMutableBufferPointer { buffer in
            while running {
                let loadedClients:Int32
                do throws(EpollError) {
                    loadedClients = try ep.wait(timeout: timeout, events: buffer)
                } catch {
                    logger.error("Epoll wait error: \(error)")
                    return
                }
                guard loadedClients > 0 else { continue }
                for i in 0..<loadedClients {
                    let event = buffer[Int(i)]
                    let eventFD = event.data.fd

                    // cancel pipe
                    if eventFD == ep.pipeFileDescriptors.read {
                        // drain pipe
                        #if DEBUG
                        logger.info("draining...")
                        #endif

                        var tmp = UInt8(0)
                        _ = read(eventFD, &tmp, 1)
                        running = false
                        break
                    }
                    if eventFD == listenFD {
                        // accept as many as possible
                        while true {
                            guard let client = acceptNewConnection() else { break }
                            let flags = UInt32(EPOLLIN.rawValue) | UInt32(EPOLLET.rawValue)
                            do throws(EpollError) {
                                try ep.add(client: client, events: flags)
                            } catch {
                                logger.error("Epoll add error: \(error)")
                            }
                        }
                        continue
                    }
                    if event.events & UInt32(EPOLLHUP.rawValue) != 0 || event.events & UInt32(EPOLLERR.rawValue) != 0 {
                        close(eventFD)
                    } else if event.events & UInt32(EPOLLIN.rawValue) != 0 { // client read/write
                        handleClient(eventFD, {
                            close(eventFD)
                        })
                    }
                }
            }
        }
    }
}

// MARK: Bind and listen
extension EpollWorker {
    /// makeReusePortListeningSocket
    #if Inlinable
    @inlinable
    #endif
    static func bindAndListen(
        port: UInt16,
        backlog: Int32,
        logger: Logger
    ) -> Int32 {
        let fd = socket(AF_INET, Int32(SOCK_STREAM.rawValue), Int32(IPPROTO_TCP))
        guard fd >= 0 else {
            fatalError("socket() failed (errno=\(errno))")
        }

        var on:Int32 = 1
        if setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on, socklen_t(MemoryLayout<Int32>.size)) != 0 {
            close(fd)
            fatalError("setsockopt(SO_REUSEADDR) failed")
        }
        if setsockopt(fd, SOL_SOCKET, SO_REUSEPORT, &on, socklen_t(MemoryLayout<Int32>.size)) != 0 {
            close(fd)
            fatalError("setsockopt(SO_REUSEPORT) failed")
        }

        var addr = sockaddr_in(
            sin_family: sa_family_t(AF_INET),
            sin_port: in_port_t(htons(port)),
            sin_addr: in_addr(s_addr: INADDR_ANY),
            sin_zero: (0,0,0,0,0,0,0,0)
        )

        let bindResult = withUnsafePointer(to: &addr) { ptr -> Int32 in
            let sockPtr = UnsafeRawPointer(ptr).assumingMemoryBound(to: sockaddr.self)
            return bind(fd, sockPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
        }

        guard bindResult == 0 else {
            close(fd)
            fatalError("bind() failed (errno=\(errno))")
        }
        guard listen(fd, backlog) == 0 else {
            close(fd)
            fatalError("listen() failed (errno=\(errno))")
        }

        setNonBlockingFD(fd)
        #if DEBUG
        logger.info("Listening for clients on http://\(Optional<String>.none ?? "localhost"):\(port) [backlog=\(backlog), fd=\(fd)]")
        #endif
        return fd
    }

    #if Inlinable
    @inlinable
    #endif
    static func setNonBlockingFD(_ fd: Int32) {
        let flags = fcntl(fd, F_GETFL, 0)
        guard flags != -1 else { fatalError("fcntl F_GETFL failed") }
        guard fcntl(fd, F_SETFL, flags | O_NONBLOCK) != -1 else { fatalError("fcntl F_SETFL failed") }
    }
}

#endif