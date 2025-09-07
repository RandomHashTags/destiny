
import DestinyBlueprint

@usableFromInline
package struct RequestHeaders: Sendable, ~Copyable {
    @usableFromInline
    let startIndex:Int

    @usableFromInline
    var _endIndex:Int? = nil

    @usableFromInline
    var headers:[String:String] = [:]

    #if Inlinable
    @inlinable
    #endif
    init(startIndex: Int) {
        self.startIndex = startIndex
    }

    #if Inlinable
    @inlinable
    #endif
    mutating func endIndex<let count: Int>(buffer: InlineArray<count, UInt8>) -> Int {
        if _endIndex == nil {
            load(buffer: buffer)
        }
        return _endIndex!
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    subscript(key: String) -> String? {
        get { headers[key] }
        set { headers[key] = newValue }
    }
}

extension RequestHeaders {
    /// Loads `headers` and `_endIndex`.
    #if Inlinable
    @inlinable
    #endif
    package mutating func load<let count: Int>(
        buffer: InlineArray<count, UInt8>
    ) {
        // performance falls off a cliff parsing headers; should we
        // just retain the buffer and record the start and end indexes
        // of things, with computed properties when and where necessary?
        Self.parseHeaders(buffer: buffer, offset: startIndex, headers: &headers)
        _endIndex = startIndex
    }
}

// MARK: Parse Headers
extension RequestHeaders {
    #if Inlinable
    @inlinable
    #endif
    static func parseHeaders<let count: Int>(
        buffer: InlineArray<count, UInt8>,
        offset: Int,
        headers: inout [String:String]
    ) {
        var skip:UInt8 = 0
        let nextLine = InlineArray<256, UInt8>(repeating: 0)
        let _:InlineArray<256, UInt8>? = buffer.split(
            separators: .carriageReturn, .lineFeed,
            defaultValue: 0,
            offset: offset,
            yield: { slice in
                if skip == 2 { // content
                } else if slice == nextLine {
                    skip += 1
                } else { // header
                    let (key, colonIndex):(InlineArray<256, UInt8>, Int) = slice.firstSlice(separator: .colon, defaultValue: 0)
                    let value:InlineArray<256, UInt8> = slice.slice(startIndex: colonIndex+2, endIndex: slice.endIndex, defaultValue: 0) // skip the colon & adjacent space
                    headers[key.unsafeString()] = value.unsafeString()
                }
                //print("slice=\(slice.unsafeString())")
            }
        )
    }
}
extension RequestHeaders {
    #if Inlinable
    @inlinable
    #endif
    static func parseHeaders2<let count: Int>(
        buffer: InlineArray<count, UInt8>,
        offset: Int,
        headers: inout [String:String]
    ) {
        let bufferCount = buffer.count
        let carriageReturnSIMD = SIMD64<UInt8>(repeating: .carriageReturn)
        var startIndex = offset
        var slice = SIMD64<UInt8>.zero
        var storage = Headers<128>()
        var i = offset
        while i < bufferCount {
            let remaining = bufferCount - i
            let simdCount:Int
            if remaining >= 64 {
                simdCount = 64
                slice = buffer.simd64(startIndex: i)
            } else {
                simdCount = remaining
                slice = .zero
                for j in 0..<simdCount {
                    slice[j] = buffer[i + j]
                }
            }
            parseHeaders(
                carriageReturnSIMD: carriageReturnSIMD,
                simd: slice,
                simdCount: simdCount,
                storage: &storage,
                offset: i,
                startIndex: &startIndex
            )
            i += simdCount
        }
    }

    #if Inlinable
    @inlinable
    #endif
    static func parseHeaders<let maxHeadersCount: Int>(
        carriageReturnSIMD: SIMD64<UInt8>,
        simd: SIMD64<UInt8>,
        simdCount: Int,
        storage: inout Headers<maxHeadersCount>,
        offset: Int,
        startIndex: inout Int
    ) {
        guard (simd .== carriageReturnSIMD) != .init(repeating: false) else { return }
        for i in 0..<simdCount {
            if simd[i] == .carriageReturn {
                storage.append(.init(startIndex: startIndex, endIndex: offset + i))
                startIndex = offset + i + 2
            }
        }
    }
}

extension RequestHeaders {
    public struct Headers<let maxHeadersCount: Int>: Sendable {
        public var count = 0
        public var values:InlineArray<maxHeadersCount, HeaderIndex>

        public init() {
            self.count = 0
            self.values = .init(repeating: .init(startIndex: 0, endIndex: 0))
        }

        #if Inlinable
        @inlinable
        #endif
        public var indices: Range<Int> {
            0..<count
        }

        #if Inlinable
        @inlinable
        #endif
        public mutating func append(_ index: HeaderIndex) {
            //guard index.startIndex < index.endIndex, count < maxHeadersCount else { return }
            values[count] = index
            count += 1
        }
    }
    public struct HeaderIndex: Sendable {
        let startIndex:Int
        let endIndex:Int

        public init(startIndex: Int, endIndex: Int) {
            self.startIndex = startIndex
            self.endIndex = endIndex
        }
    }
}