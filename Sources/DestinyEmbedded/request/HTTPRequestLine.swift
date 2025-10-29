
import UnwrapArithmeticOperators
import VariableLengthArray

/// Default HTTP Request Line implementation that includes the request method, target and HTTP version.
public struct HTTPRequestLine: Sendable, ~Copyable {
    /// Index in a buffer where the request method ends.
    public let methodEndIndex:Int

    /// Index in a buffer where the target query starts.
    public let pathQueryStartIndex:Int?

    /// Index in a buffer where the contents actually ends.
    public let endIndex:Int

    /// Mapped HTTP Version of a request.
    public let version:HTTPVersion

    #if Inlinable
    @inlinable
    #endif
    public init(
        methodEndIndex: Int,
        pathQueryStartIndex: Int?,
        version: HTTPVersion,
        endIndex: Int
    ) {
        self.methodEndIndex = methodEndIndex
        self.pathQueryStartIndex = pathQueryStartIndex
        self.version = version
        self.endIndex = endIndex
    }

    /// Number of bytes of the target.
    #if Inlinable
    @inlinable
    #endif
    public var pathCount: Int {
        pathEndIndex -! methodEndIndex -! 1
    }

    /// Index in a buffer where the target ends.
    #if Inlinable
    @inlinable
    #endif
    public var pathEndIndex: Int {
        endIndex -! 9
    }

    #if Inlinable
    @inlinable
    #endif
    public func path<let count: Int>(
        buffer: InlineArray<count, UInt8>,
        _ closure: (consuming VLArray<UInt8>) -> Void
    ) {
        let pathCount = pathCount
        withUnsafeTemporaryAllocation(of: UInt8.self, capacity: pathCount, { pathBuffer in
            var offset = methodEndIndex +! 1
            if pathCount <= 128 {
                for i in 0..<pathCount {
                    pathBuffer[i] = buffer[unchecked: offset]
                    offset +=! 1
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
    public func method<let count: Int>(
        buffer: InlineArray<count, UInt8>,
        _ closure: (consuming VLArray<UInt8>) -> Void
    ) {
        VLArray.create(amount: methodEndIndex, initialize: {
            buffer[unchecked: $0]
        }, closure)
    }

    #if Inlinable
    @inlinable
    #endif
    public func simd<let count: Int>(
        buffer: InlineArray<count, UInt8>,
    ) -> SIMD64<UInt8> {
        var simd = SIMD64<UInt8>()
        withUnsafePointer(to: buffer, { bufferPointer in
            withUnsafeMutablePointer(to: &simd, {
                copyMemory(.init($0), bufferPointer, min(64, endIndex))
            })
        })
        return simd
    }

    #if Inlinable
    @inlinable
    #endif
    public func copy() -> Self {
        Self(
            methodEndIndex: methodEndIndex,
            pathQueryStartIndex: pathQueryStartIndex,
            version: version,
            endIndex: endIndex
        )
    }
}

// MARK: Load
extension HTTPRequestLine {
    /// Tries parsing a `HTTPRequestLine` from a buffer.
    /// 
    /// - Throws: `SocketError`
    #if Inlinable
    @inlinable
    #endif
    public static func load<let count: Int>(
        buffer: borrowing InlineByteBuffer<count>
    ) throws(SocketError) -> Self {
        var methodEndIndex = 0
        let bufferSpan = buffer.buffer.span
        var offset = 0
        while offset < bufferSpan.count, methodEndIndex == 0 {
            if bufferSpan[unchecked: offset] == .space {
                methodEndIndex = offset
                break
            }
            offset +=! 1
        }
        guard methodEndIndex != 0 else {
            throw .custom("malformedRequest;methodEndIndex == 0")
        }
        offset +=! 1
        var pathQueryStartIndex:Int? = nil
        var pathEndIndex = 0
        var i = offset
        loop: while i < bufferSpan.count {
            switch bufferSpan[unchecked: i] {
            case .space:
                pathEndIndex = i
                break loop
            case .questionMark:
                i +=! 1
                if i < bufferSpan.count {
                    pathQueryStartIndex = i
                }
            default:
                i +=! 1
            }
        }
        guard pathEndIndex != 0 else {
            throw .custom("malformedRequest;targetPathEndIndex == 0")
        }
        let pathCount = pathEndIndex -! methodEndIndex -! 1
        offset +=! (pathCount +! 1)
        guard offset +! 8 < bufferSpan.count else {
            throw .custom("malformedRequest;not enough bytes for the HTTP Version")
        }
        let versionUInt64 = bufferSpan.bytes.unsafeLoadUnaligned(fromUncheckedByteOffset: offset, as: UInt64.self)
        guard let version = HTTPVersion.init(token: versionUInt64.bigEndian) else {
            throw .custom("malformedRequest;unrecognized HTTPVersion: (bigEndian: \(versionUInt64.bigEndian), littleEndian: \(versionUInt64.littleEndian))")
        }
        return HTTPRequestLine.init(
            methodEndIndex: methodEndIndex,
            pathQueryStartIndex: pathQueryStartIndex,
            version: version,
            endIndex: pathEndIndex +! 9
        )
    }
}