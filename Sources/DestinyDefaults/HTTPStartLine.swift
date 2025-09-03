
import DestinyBlueprint
import VariableLengthArray

/// Default HTTP Start Line implementation.
public struct HTTPStartLine<let bufferCount: Int>: HTTPStartLineProtocol, ~Copyable {
    public let buffer:InlineArray<bufferCount, UInt8>
    public let methodEndIndex:Int
    public let pathQueryStartIndex:Int?
    public let endIndex:Int
    public let version:HTTPVersion

    #if Inlinable
    @inlinable
    #endif
    public init(
        buffer: InlineArray<bufferCount, UInt8>,
        methodEndIndex: Int,
        pathQueryStartIndex: Int?,
        version: HTTPVersion,
        endIndex: Int
    ) {
        self.buffer = buffer
        self.methodEndIndex = methodEndIndex
        self.pathQueryStartIndex = pathQueryStartIndex
        self.version = version
        self.endIndex = endIndex
    }

    #if Inlinable
    @inlinable
    #endif
    public var pathCount: Int {
        pathEndIndex - methodEndIndex - 1
    }

    #if Inlinable
    @inlinable
    #endif
    public var pathEndIndex: Int {
        endIndex - 9
    }

    #if Inlinable
    @inlinable
    #endif
    public func path(
        _ closure: (consuming VLArray<UInt8>) -> Void)
     {
        let pathCount = pathCount
        withUnsafeTemporaryAllocation(of: UInt8.self, capacity: pathCount, { pathBuffer in
            var offset = methodEndIndex + 1
            if pathCount <= 128 {
                for i in 0..<pathCount {
                    pathBuffer[i] = buffer[offset]
                    offset += 1
                }
            } else {
                buffer.span.withUnsafeBufferPointer {
                    copyMemory(pathBuffer.baseAddress!, $0.baseAddress! + offset, pathCount)
                }
            }
            let pathArray = VLArray<UInt8>(_storage: pathBuffer)
            closure(pathArray)
        })
    }

    #if Inlinable
    @inlinable
    #endif
    public func method(
        _ closure: (consuming VLArray<UInt8>) -> Void
    ) {
        VLArray.create(amount: methodEndIndex, initialize: {
            buffer[$0]
        }, closure)
    }
}

// MARK: Load
extension HTTPStartLine {
    #if Inlinable
    @inlinable
    #endif
    public static func load(
        buffer: InlineArray<bufferCount, UInt8>
    ) throws(SocketError) -> Self {
        var err:SocketError? = nil
        var methodEndIndex = 0
        var pathQueryStartIndex:Int? = nil
        var pathEndIndex = 0
        var versionUInt64:UInt64 = 0
        buffer.withUnsafeBufferPointer { bufferPointer in
            guard let base = bufferPointer.baseAddress else {
                err = .malformedRequest("bufferPointer.baseAddress == nil")
                return
            }
            var offset = 0
            while offset < bufferPointer.count, methodEndIndex == 0 {
                if bufferPointer[offset] == .space {
                    methodEndIndex = offset
                    break
                }
                offset += 1
            }
            guard methodEndIndex != 0 else {
                err = .malformedRequest("methodEndIndex == 0")
                return
            }
            offset += 1
            var i = offset
            loop: while i < bufferPointer.count {
                switch bufferPointer[i] {
                case .space:
                    pathEndIndex = i
                    break loop
                case .questionMark:
                    i += 1
                    if i < bufferPointer.count {
                        pathQueryStartIndex = i
                    }
                default:
                    i += 1
                }
            }
            guard pathEndIndex != 0 else {
                err = .malformedRequest("targetPathEndIndex == 0")
                return
            }
            let pathCount = pathEndIndex - methodEndIndex - 1
            offset += pathCount + 1
            guard offset + 8 < bufferPointer.count else {
                err = .malformedRequest("not enough bytes for the HTTP Version")
                return
            }
            versionUInt64 = UnsafeRawPointer(base).load(fromByteOffset: offset, as: UInt64.self)
        }
        if let err {
            throw err
        }
        guard let version = HTTPVersion.init(token: versionUInt64.bigEndian) else {
            throw .malformedRequest("unrecognized HTTPVersion: (bigEndian: \(versionUInt64.bigEndian), littleEndian: \(versionUInt64.littleEndian))")
        }
        let startLine = HTTPStartLine.init(
            buffer: buffer,
            methodEndIndex: methodEndIndex,
            pathQueryStartIndex: pathQueryStartIndex,
            version: version,
            endIndex: pathEndIndex + 9
        )
        return startLine
    }
}

// MARK: Load minimal
extension HTTPStartLine {
    #if Inlinable
    @inlinable
    #endif
    public static func loadMinimal<T: InlineArrayProtocol>(
        buffer: T
    ) throws(SocketError) -> (methodEndIndex: Int, pathEndIndex: Int, httpVersion: HTTPVersion) where T.Element == UInt8 {
        var methodEndIndex = 0
        var pathEndIndex = 0
        var version = HTTPVersion.v0_9
        var err:SocketError? = nil
        buffer.withUnsafeBufferPointer { bufferPointer in
            guard let base = bufferPointer.baseAddress else {
                err = .malformedRequest("bufferPointer.baseAddress == nil")
                return
            }
            var offset = 0
            while offset < bufferPointer.count, methodEndIndex == 0 {
                if bufferPointer[offset] == .space {
                    methodEndIndex = offset
                    break
                }
                offset += 1
            }
            guard methodEndIndex != 0 else {
                err = .malformedRequest("methodEndIndex == 0")
                return
            }
            offset += 1
            for i in offset..<bufferPointer.count {
                if bufferPointer[i] == .space {
                    pathEndIndex = i
                    break
                }
            }
            guard pathEndIndex != 0 else {
                err = .malformedRequest("targetPathEndIndex == 0")
                return
            }
            guard pathEndIndex + 9 < bufferPointer.count else {
                err = .malformedRequest("not enough bytes for the HTTP Version")
                return
            }
            var versionUInt64:UInt64 = 0
            copyMemory(&versionUInt64, base + pathEndIndex + 1, 8)
            guard let httpVersion = HTTPVersion.init(token: versionUInt64.bigEndian) else {
                err = .malformedRequest("unrecognized HTTPVersion: \(versionUInt64.bigEndian)")
                return
            }
            version = httpVersion
        }
        if let err {
            throw err
        } else {
            return (methodEndIndex, pathEndIndex, version)
        }
    }
}