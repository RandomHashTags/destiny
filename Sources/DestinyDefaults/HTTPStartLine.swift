
import DestinyBlueprint
import VariableLengthArray

/// Default HTTP Start Line implementation.
public struct HTTPStartLine: HTTPStartLineProtocol, ~Copyable {
    public let method:VLArray<UInt8>
    public let path:VLArray<UInt8>
    public let pathQueryStartIndex:Int?
    public let endIndex:Int
    public let version:HTTPVersion

    @inlinable
    public init(
        method: consuming VLArray<UInt8>,
        pathQueryStartIndex: Int?,
        path: consuming VLArray<UInt8>,
        version: HTTPVersion,
        endIndex: Int
    ) {
        self.method = method
        self.pathQueryStartIndex = pathQueryStartIndex
        self.path = path
        self.version = version
        self.endIndex = endIndex
    }

    @inlinable
    public var pathEndIndex: Int {
        endIndex - 9
    }
}

// MARK: Load
extension HTTPStartLine {
    @inlinable
    public static func load<T: InlineArrayProtocol>(
        buffer: T,
        _ body: (consuming Self) throws(SocketError) -> Void
    ) throws(SocketError) where T.Element == UInt8 {
        var err:SocketError? = nil
        buffer.withUnsafeBufferPointer { bufferPointer in
            guard let base = bufferPointer.baseAddress else {
                err = .malformedRequest("bufferPointer.baseAddress == nil")
                return
            }
            var offset = 0
            var methodEndIndex = 0
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
            var pathQueryStartIndex:Int? = nil
            var pathEndIndex = 0
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
            withUnsafeTemporaryAllocation(of: UInt8.self, capacity: methodEndIndex, { methodBuffer in
                for i in 0..<methodEndIndex {
                    methodBuffer[i] = bufferPointer[i]
                }
                offset = methodEndIndex + 1
                let pathCount = pathEndIndex - methodEndIndex - 1
                withUnsafeTemporaryAllocation(of: UInt8.self, capacity: pathCount, { pathBuffer in
                    if pathCount <= 128 {
                        for i in 0..<pathCount {
                            pathBuffer[i] = bufferPointer[offset]
                            offset += 1
                        }
                        offset += 1
                    } else {
                        copyMemory(pathBuffer.baseAddress!, bufferPointer.baseAddress! + offset, pathCount)
                        offset += pathCount + 1
                    }
                    guard offset + 8 < bufferPointer.count else {
                        err = .malformedRequest("not enough bytes for the HTTP Version")
                        return
                    }
                    var versionUInt64:UInt64 = 0
                    copyMemory(&versionUInt64, base + offset, 8)
                    guard let version = HTTPVersion.init(token: versionUInt64.bigEndian) else {
                        err = .malformedRequest("unrecognized HTTPVersion: (bigEndian: \(versionUInt64.bigEndian), littleEndian: \(versionUInt64.littleEndian))")
                        return
                    }
                    let methodArray = VLArray<UInt8>(_storage: methodBuffer)
                    let pathArray = VLArray<UInt8>(_storage: pathBuffer)
                    let startLine = HTTPStartLine.init(
                        method: methodArray,
                        pathQueryStartIndex: pathQueryStartIndex,
                        path: pathArray,
                        version: version,
                        endIndex: pathEndIndex + 9
                    )
                    do throws(SocketError) {
                        try body(startLine)
                        return
                    } catch {
                        err = error
                    }
                })
            })
        }
        if let err {
            throw err
        }
    }
}

// MARK: Load minimal
extension HTTPStartLine {
    @inlinable
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