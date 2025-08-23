
// TODO: finish
/*
#if os(Linux)
import Glibc

@_silgen_name("syscall")
private func c_syscall(
    _ n: CLong,
    _ a1: CLong,
    _ a2: CLong,
    _ a3: CLong,
    _ a4: CLong,
    _ a5: UnsafeRawPointer?,
    _ a6: CLong
) -> CLong

@inline(__always)
private func sysErrno(_ code: Int32 = errno) -> String {
    if let cstr = strerror(code) {
        return String(cString: cstr)
    } else {
        return "errno \(code)"
    }
}

@inline(__always)
private func pageSize() -> Int {
    let sz = sysconf(Int32(_SC_PAGESIZE))
    return sz > 0 ? Int(sz) : 4096
}

@inline(__always)
private func roundUp(_ x: Int, to align: Int) -> Int {
    (x + (align-1)) & ~(align-1)
}

public struct IO_Uring {
    // MARK: - Syscall numbers (x86_64 + aarch64). Add more arches as needed.
    #if os(Linux)
    #if arch(x86_64)
        static let SYS_IO_URING_SETUP:CLong    = 425
        static let SYS_IO_URING_ENTER:CLong    = 426
        static let SYS_IO_URING_REGISTER:CLong = 427
    #elseif arch(arm64)
        // aarch64
        static let SYS_IO_URING_SETUP:CLong    = 425
        static let SYS_IO_URING_ENTER:CLong    = 426
        static let SYS_IO_URING_REGISTER:CLong = 427
    #else
        #error("Unsupported architecture: define io_uring syscall numbers for this arch")
    #endif
    #endif

    // MARK: - Kernel constants (subset)

    // io_uring_setup flags
    static var IORING_SETUP_IOPOLL: UInt32     { 1 << 0}
    static var IORING_SETUP_SQPOLL: UInt32     { 1 << 1}
    static var IORING_SETUP_SQ_AFF: UInt32     { 1 << 2}
    static var IORING_SETUP_CQSIZE: UInt32     { 1 << 3}
    static var IORING_SETUP_CLAMP: UInt32      { 1 << 4}
    static var IORING_SETUP_ATTACH_WQ: UInt32  { 1 << 5}
    static var IORING_SETUP_R_DISABLED: UInt32 { 1 << 6}

    // io_uring_enter flags
    static var IORING_ENTER_GETEVENTS: UInt32 { 1 << 0 }
    static var IORING_ENTER_SQ_WAKEUP: UInt32 { 1 << 1 }

    // Features (params.features)
    static var IORING_FEAT_SINGLE_MMAP: UInt32 { 1 << 0 }

    // Submission Queue Entry flags
    var IOSQE_FIXED_FILE: UInt8  { 1 << 0}
    var IOSQE_IO_DRAIN: UInt8    { 1 << 1}
    var IOSQE_IO_LINK: UInt8     { 1 << 2}
    var IOSQE_IO_HARDLINK: UInt8 { 1 << 3}
    var IOSQE_ASYNC: UInt8       { 1 << 4}

    // Timeout flags
    var IORING_TIMEOUT_ABS: UInt32 { 1 << 0}
    var IORING_TIMEOUT_BOOTTIME: UInt32 { 1 << 1}
    var IORING_TIMEOUT_REALTIME: UInt32 { 1 << 2}
    var IORING_TIMEOUT_ETIME_SUCCESS: UInt32 { 1 << 3}

    // Parameters passed to io_uring_setup
    @frozen
    public struct io_uring_params {
        public var submissionQueueEntries:UInt32 = 0
        public var completionQueueEntries:UInt32 = 0
        public var flags:UInt32 = 0
        public var submissionQueueThreadCPU:UInt32 = 0
        public var submissionQueueThreadIdle:UInt32 = 0
        public var features:UInt32 = 0
        public var wq_fileDescriptor:UInt32 = 0
        public var resv:(UInt32, UInt32, UInt32) = (0, 0, 0)
        public var submissionQueueOffsets = IOSubmissionQueueRingOffsets()
        public var completionQueueOffsets = IOCompletionQueueRingOffsets()
    }

    // MARK: - Public Wrapper

    public final class IoUring {
        public let ringFileDescriptor:Int32
        public let entries:Int

        // Memory maps
        private var submissionQueuePointer:UnsafeMutableRawPointer
        private var completionQueuePointer:UnsafeMutableRawPointer
        private var submissionQueueEntryPointer:UnsafeMutablePointer<SubmissionQueueEntry>

        private var submissionQueue:SubmissionQueueRing
        private var completionQueue:CompletionQueueRing

        // Submission queue bookkeeping in userspace
        private var submissionQueueEntryCount = 0

        public struct Params {
            public var flags:UInt32 = 0

            public init(
                flags: UInt32 = 0
            ) {
                self.flags = flags
            } 
        }

        public init(
            entries: Int,
            params: inout io_uring_params
        ) throws(IOUringError) {
            var p = params // kernel writes back offsets/features
            let fileDescriptor = c_syscall(
                SYS_IO_URING_SETUP,
                CLong(CUnsignedInt(entries)),
                withUnsafePointer(to: &p) {
                    UnsafeRawPointer($0)
                }
            )
            if fileDescriptor < 0 {
                throw IOUringError.syscall("io_uring_setup", errno)
            }
            ringFileDescriptor = Int32(fileDescriptor)
            self.entries = entries

            // Compute mmap sizes
            let pageSize = pageSize()
            let submissionQueueRingSize = Int(p.submissionQueueOffsets.array) + Int(p.submissionQueueEntries) * MemoryLayout<UInt32>.stride
            let completionQueueRingSize = Int(p.completionQueueOffsets.cqes) + Int(p.completionQueueEntries) * MemoryLayout<CompletionQueueEntry>.stride
            let useSingle = (p.features & IORING_FEAT_SINGLE_MMAP) != 0

            // Map rings
            let mapSize = roundUp(max(submissionQueueRingSize, completionQueueRingSize), to: pageSize)
            let submissionQueueMap:UnsafeMutableRawPointer = mmap(
                nil,
                useSingle ? mapSize : submissionQueueRingSize, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_POPULATE,
                ringFileDescriptor,
                Int(MAP_HUGETLB) * 0 + 0
            )
            if submissionQueueMap == MAP_FAILED {
                throw .syscall("mmap SQ", errno)
            }
            let completionQueueMap:UnsafeMutableRawPointer
            if useSingle {
                completionQueueMap = submissionQueueMap
            } else {
                completionQueueMap = mmap(nil, completionQueueRingSize, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_POPULATE, ringFileDescriptor, 0x80000000 /* IORING_OFF_CQ_RING, but we use 0 and rely on offsets */)
            if completionQueueMap == MAP_FAILED {
                munmap(submissionQueueMap, useSingle ? mapSize : submissionQueueRingSize)
                throw .syscall("mmap CQ", errno) }
            }

            // Map SQEs region (separate from rings)
            let submissionQueueEntrySize = Int(p.submissionQueueEntries) * MemoryLayout<SubmissionQueueEntry>.stride
            let submissionQueueEntryMap:UnsafeMutableRawPointer = mmap(nil, submissionQueueEntrySize, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_POPULATE, ringFileDescriptor, 0x10000000 /* IORING_OFF_SQES */)
            if submissionQueueEntryMap == MAP_FAILED {
                munmap(submissionQueueMap, useSingle ? mapSize : submissionQueueRingSize)
                if !useSingle {
                    munmap(completionQueueMap, completionQueueRingSize)
                }
                throw .syscall("mmap SQEs", errno)
            }

            // Bind pointers according to offsets
            func off<T>(
                _ base: UnsafeMutableRawPointer,
                _ off: UInt32,
                _: T.Type
            ) -> UnsafeMutablePointer<T> {
                return (base + Int(off)).assumingMemoryBound(to: T.self)
            }
            submissionQueuePointer = submissionQueueMap
            completionQueuePointer = completionQueueMap
            submissionQueueEntryPointer = submissionQueueEntryMap.assumingMemoryBound(to: SubmissionQueueEntry.self)
            submissionQueue = SubmissionQueueRing(
                khead: off(submissionQueueMap, p.submissionQueueOffsets.head, UInt32.self),
                ktail: off(submissionQueueMap, p.submissionQueueOffsets.tail, UInt32.self),
                ringMask: off(submissionQueueMap, p.submissionQueueOffsets.ringMask, UInt32.self),
                ringEntries: off(submissionQueueMap, p.submissionQueueOffsets.ringEntries, UInt32.self),
                flags: off(submissionQueueMap, p.submissionQueueOffsets.flags, UInt32.self),
                dropped: off(submissionQueueMap, p.submissionQueueOffsets.dropped, UInt32.self),
                array: off(submissionQueueMap, p.submissionQueueOffsets.array, UInt32.self)
            )
            completionQueue = CompletionQueueRing(
                khead: off(completionQueueMap, p.completionQueueOffsets.head, UInt32.self),
                ktail: off(completionQueueMap, p.completionQueueOffsets.tail, UInt32.self),
                ringMask: off(completionQueueMap, p.completionQueueOffsets.ringMask, UInt32.self),
                ringEntries: off(completionQueueMap, p.completionQueueOffsets.ringEntries, UInt32.self),
                overflow: off(completionQueueMap, p.completionQueueOffsets.overflow, UInt32.self),
                cqes: off(completionQueueMap, p.completionQueueOffsets.cqes, CompletionQueueEntry.self)
            )
            submissionQueueEntryCount = 0
            params = p // expose features/offsets to caller if needed
        }

        deinit {
            munmap(submissionQueueEntryPointer, Int(entries) * MemoryLayout<SubmissionQueueEntry>.stride)
            // We don't know if single-mmap sized; conservatively unmap one large page region.
            // In practice, this is fine for process teardown; for libraries, carry sizes.
            // (You can store sq/cq sizes in the instance if you need precise unmap.)
            // Attempt to unmap a few likely sizes:
            _ = munmap(submissionQueuePointer, 1 << 20)
            _ = munmap(completionQueuePointer, 1 << 20)
            close(ringFileDescriptor)
        }

        // MARK: SQE acquisition

        @inline(__always)
        private func nextSubmissionQueueEntry() -> UnsafeMutablePointer<SubmissionQueueEntry>? {
            let head = submissionQueue.khead.pointee
            let tail = submissionQueue.ktail.pointee
            let mask = submissionQueue.ringMask.pointee
            if tail - head >= submissionQueue.ringEntries.pointee { // full
                return nil
            }
            let index = tail & mask
            // slot in SQ array points to SQE index
            submissionQueue.array.advanced(by: Int(index)).pointee = index
            let sqe = submissionQueueEntryPointer.advanced(by: Int(index))
            // zero SQE
            sqe.initialize(to: SubmissionQueueEntry())
            submissionQueue.ktail.pointee = tail &+ 1
            submissionQueueEntryCount &+= 1
            return sqe
        }

        // MARK: Prepare helpers (common ops)

        @discardableResult
        public func prepareNOP(
            userData: UInt64 = 0
        ) -> Bool {
            guard let sqe = nextSubmissionQueueEntry() else { return false }
            sqe.pointee.opcode = IORING_OP.nop.rawValue
            sqe.pointee.userData = userData
            return true
        }

        @discardableResult
        public func prepareREADV(
            fd: Int32,
            iov: UnsafePointer<iovec>,
            iovCount: Int32,
            offset: UInt64 = 0,
            userData: UInt64 = 0
        ) -> Bool {
            guard let sqe = nextSubmissionQueueEntry() else { return false }
            sqe.pointee.opcode = IORING_OP.readv.rawValue
            sqe.pointee.fileDescriptor = fd
            sqe.pointee.addr = UInt64(UInt(bitPattern: iov))
            sqe.pointee.len = UInt32(bitPattern: iovCount)
            sqe.pointee.offset = offset
            sqe.pointee.userData = userData
            return true
        }

        @discardableResult
        public func prepareWRITEV(
            fd: Int32,
            iov: UnsafePointer<iovec>,
            iovCount: Int32,
            offset: UInt64 = 0,
            userData: UInt64 = 0
        ) -> Bool {
            guard let sqe = nextSubmissionQueueEntry() else { return false }
            sqe.pointee.opcode = IORING_OP.writev.rawValue
            sqe.pointee.fileDescriptor = fd
            sqe.pointee.addr = UInt64(UInt(bitPattern: iov))
            sqe.pointee.len = UInt32(bitPattern: iovCount)
            sqe.pointee.offset = offset
            sqe.pointee.userData = userData
            return true
        }

        @discardableResult
        public func prepareTIMEOUT(
            ts: inout __kernel_timespec,
            count: UInt32 = 0,
            flags: UInt32 = 0,
            userData: UInt64 = 0
        ) -> Bool {
            guard let sqe = nextSubmissionQueueEntry() else { return false }
            sqe.pointee.opcode = IORING_OP.timeout.rawValue
            sqe.pointee.addr = UInt64(UInt(bitPattern: withUnsafePointer(to: &ts) { UnsafeRawPointer($0) }))
            sqe.pointee.len = count
            sqe.pointee.op_flags = flags
            sqe.pointee.userData = userData
            return true
        }

        // MARK: Submit & wait

        /// Submit queued entries.
        /// - Returns: number submitted.
        @discardableResult
        public func submit() throws(IOUringError) -> Int {
            let toSubmit = submissionQueueEntryCount
            if toSubmit == 0 {
                return 0
            }
            // Enter with submit only
            let ret = c_syscall(
                SYS_IO_URING_ENTER,
                CLong(ringFileDescriptor),
                CLong(toSubmit),
                CLong(0),
                CLong(0),
                nil,
                0
            )
            if ret < 0 {
                throw .syscall("io_uring_enter submit", errno)
            }
            submissionQueueEntryCount = 0
            return Int(ret)
        }

        /// Block until at least `want` completions are available and/or submit pending SQEs.
        public func enter(
            want: Int = 1
        ) throws(IOUringError) {
            let ret = c_syscall(
                SYS_IO_URING_ENTER,
                CLong(ringFileDescriptor),
                CLong(submissionQueueEntryCount),
                CLong(want),
                CLong(IORING_ENTER_GETEVENTS),
                nil,
                0
            )
            if ret < 0 {
                throw IOUringError.syscall("io_uring_enter (submit+wait)", errno)
            }
            submissionQueueEntryCount = 0
        }

        /// Try pop a CQE. Returns nil if none available.
        public func tryPopCompletionQueueEntry() -> CompletionQueueEntry? {
            let head = completionQueue.khead.pointee
            let tail = completionQueue.ktail.pointee
            if head == tail {
                return nil
            }
            let index = head & completionQueue.ringMask.pointee
            let entry = completionQueue.cqes.advanced(by: Int(index)).pointee
            completionQueue.khead.pointee = head &+ 1
            // A store fence is advisable here for cross-thread safety.
            return entry
        }

        /// Blocking wait for completion queue entries.
        public func waitCompletionQueueEntry(
            entries: Int = 1
        ) -> CompletionQueueEntry {
            while true {
                if let e = tryPopCompletionQueueEntry() {
                    return e
                }
                // Ask kernel to wake when at least `entries` events are ready.
                let _ = c_syscall(
                    SYS_IO_URING_ENTER,
                    CLong(ringFileDescriptor),
                    0,
                    CLong(entries),
                    CLong(IORING_ENTER_GETEVENTS),
                    nil,
                    0
                )
            }
        }
    }

    // MARK: - __kernel_timespec (Linux)
    @frozen
    public struct __kernel_timespec {
        public var tv_sec:Int64
        public var tv_nsec:Int64

        public init(
            tv_sec: Int64,
            tv_nsec: Int64
        ) {
            self.tv_sec = tv_sec
            self.tv_nsec = tv_nsec
        }
    }
}

    /*// MARK: - Small demo (READV + TIMEOUT + NOP)

    #if DEMO_IO_URING
    func demo() throws {
    var params = io_uring_params()
    let ring = try IoUring(entries: 256, params: &params)

    // Prepare a NOP with user_data 1
    _ = ring.prepareNOP(userData: 1)

    // Prepare a 50ms timeout with user_data 2
    var ts = __kernel_timespec(tv_sec: 0, tv_nsec: 50_000_000)
    _ = ring.prepareTIMEOUT(ts: &ts, userData: 2)

    try ring.enter(want: 1) // submit both and wait for at least 1 event

    // Drain CQEs
    while let cqe = ring.tryPopCQE() {
        print("CQE: user=\(cqe.user_data) res=\(cqe.res)")
    }
    }

    try! demo()
    #endif*/


// MARK: IORING_OP
extension IO_Uring {
    public enum IORING_OP: UInt8 {
        case nop           = 0
        case readv         = 1
        case writev        = 2
        case fsync         = 3
        case readFixed     = 4
        case writeFixed    = 5
        case pollAdd       = 6
        case pollRemove    = 7
        case syncFileRange = 8
        case sendmsg       = 19
        case recvmsg       = 20
        case timeout       = 23
        case timeoutRemove = 24
        case accept        = 13
        case connect       = 14
    }
}

// MARK: IOSubmissionQueueRingOffsets
extension IO_Uring {
    // Offsets for mmap (from params.sq_off / cq_off)
    @frozen
    public struct IOSubmissionQueueRingOffsets {
        public var head:UInt32
        public var tail:UInt32
        public var ringMask:UInt32
        public var ringEntries:UInt32
        public var flags:UInt32
        public var dropped:UInt32
        public var array:UInt32
        public var resv1:UInt32
        public var resv2:UInt64

        public init(
            head: UInt32 = 0,
            tail: UInt32 = 0,
            ring_mask: UInt32 = 0,
            ring_entries: UInt32 = 0,
            flags: UInt32 = 0,
            dropped: UInt32 = 0,
            array: UInt32 = 0,
            resv1: UInt32 = 0,
            resv2: UInt64 = 0
        ) {
            self.head = head
            self.tail = tail
            self.ringMask = ring_mask
            self.ringEntries = ring_entries
            self.flags = flags
            self.dropped = dropped
            self.array = array
            self.resv1 = resv1
            self.resv2 = resv2
        }
    }
}

// MARK: IOCompletionQueueRingOffsets
extension IO_Uring {
    @frozen
    public struct IOCompletionQueueRingOffsets {
        public var head:UInt32
        public var tail:UInt32
        public var ringMask:UInt32
        public var ringEntries:UInt32
        public var overflow:UInt32
        public var cqes:UInt32
        public var resv:UInt64

        public init(
            head: UInt32 = 0,
            tail: UInt32 = 0,
            ring_mask: UInt32 = 0,
            ring_entries: UInt32 = 0,
            overflow: UInt32 = 0,
            cqes: UInt32 = 0,
            resv: UInt64 = 0
        ) {
            self.head = head
            self.tail = tail
            self.ringMask = ring_mask
            self.ringEntries = ring_entries
            self.overflow = overflow
            self.cqes = cqes
            self.resv = resv
        }
    }
}

// MARK: SubmissionQueueRing
extension IO_Uring {
    @usableFromInline
    struct SubmissionQueueRing {
        var khead:UnsafeMutablePointer<UInt32>
        var ktail:UnsafeMutablePointer<UInt32>
        var ringMask:UnsafeMutablePointer<UInt32>
        var ringEntries:UnsafeMutablePointer<UInt32>
        var flags:UnsafeMutablePointer<UInt32>
        var dropped:UnsafeMutablePointer<UInt32>
        var array:UnsafeMutablePointer<UInt32>
    }
}

// MARK: SubmissionQueueEntry
extension IO_Uring {
    @frozen
    public struct SubmissionQueueEntry {
        public var opcode:UInt8 = 0
        public var flags:UInt8 = 0
        public var ioprio:UInt16 = 0
        public var fileDescriptor:Int32 = 0
        public var offset:UInt64 = 0
        public var addr:UInt64 = 0
        public var len:UInt32 = 0
        public var op_flags:UInt32 = 0 // rw_flags / accept_flags / timeout_flags
        public var userData:UInt64 = 0
        public var buf_group:UInt16 = 0
        public var personality:UInt16 = 0
        public var splice_fd_in:Int32 = 0
        public var __pad2:(UInt64, UInt64) = (0, 0)
    }
}

// MARK: CompletionQueueRing
extension IO_Uring {
    @usableFromInline
    struct CompletionQueueRing {
        var khead:UnsafeMutablePointer<UInt32>
        var ktail:UnsafeMutablePointer<UInt32>
        var ringMask:UnsafeMutablePointer<UInt32>
        var ringEntries:UnsafeMutablePointer<UInt32>
        var overflow:UnsafeMutablePointer<UInt32>
        var cqes:UnsafeMutablePointer<CompletionQueueEntry>
    }
}

// MARK: CompletionQueueEntry
extension IO_Uring {
    @frozen
    public struct CompletionQueueEntry {
        public var user_data:UInt64 = 0
        public var res:Int32 = 0
        public var flags:UInt32 = 0
    }
}

// MARK: IOUringError
public enum IOUringError: Error, CustomStringConvertible {
    case syscall(String, Int32)

    public var description: String {
        switch self {
        case .syscall(let name, let code): "\(name) failed: \(sysErrno(code)) (errno=\(code))"
        }
    }
}

#endif
*/