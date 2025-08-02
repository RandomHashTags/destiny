
import DestinyBlueprint

/// Default storage for request data.
public struct Request: HTTPRequestProtocol {
    public let path:[String]
    public let startLine:DestinyRoutePathType
    public let headers:HTTPRequestHeaders
    public let newStartLine:HTTPStartLine

    /*public var description: String {
        return startLine.leadingString() + " (" + methodSIMD.leadingString() + "; " + uri.leadingString() + ";" + version.simd.leadingString() + ")"
    }*/

    public init(
        path: [String],
        startLine: DestinyRoutePathType,
        headers: HTTPRequestHeaders,
        newStartLine: HTTPStartLine
    ) {
        self.path = path
        self.startLine = startLine
        self.headers = headers
        self.newStartLine = newStartLine
    }

    @inlinable
    public func forEachPath(offset: Int = 0, _ yield: (String) -> Void) {
        var i = offset
        while i < path.count {
            yield(path[i])
            i += 1
        }
    }

    @inlinable
    public func path(at index: Int) -> String {
        path[index]
    }

    @inlinable
    public var pathCount: Int {
        path.count
    }

    @inlinable
    public func isMethod(_ method: some HTTPRequestMethodProtocol) -> Bool {
        method.rawNameString() == newStartLine.method.string()
    }

    @inlinable
    public func header(forKey key: String) -> String? {
        headers[key]
    }
}

// MARK: Load
extension Request {
    @inlinable
    public static func load(socket: borrowing some HTTPSocketProtocol & ~Copyable) throws -> Request {
        var (buffer, read) = try socket.readBuffer()
        if read <= 0 {
            throw SocketError.malformedRequest()
        }
        /*var lineIndex = 0
        try buffer.split(separator: .carriageReturn, defaultValue: 0, yield: { array in
            if lineIndex != 0 && array.itemAt(index: 0) != .lineFeed {
                throw SocketError.malformedRequest()
            }
            //print("HTTPStartLine;init;buffer.split;inlineVLArray;count=\(array.count);string=\(array.string(offset: lineIndex == 0 ? 0 : 1))")
            lineIndex += 1
            return false
        })*/
        var startLine = DestinyRoutePathType()
        let newStartLine = try HTTPStartLine(buffer: buffer)
        let path = newStartLine.path.string().split(separator: "/").map { String($0) }
        for i in 0..<newStartLine.endIndex {
            startLine[i] = buffer.itemAt(index: i)
        }

        // performance falls off a cliff parsing headers; should we
        // just retain the buffer and record the start and end indexes
        // of things, with computed properties when and where necessary?
        var headers:[String:String] = [:]
        //let _ = Self.parseHeaders(buffer: buffer, offset: newStartLine.endIndex + 2, headers: &headers)

        while true {
            if read < buffer.count {
                break
            }
            (buffer, read) = try socket.readBuffer()
            if read <= 0 {
                break
            }
        }
        return Request(
            path: path,
            startLine: startLine,
            headers: .init(headers),
            newStartLine: newStartLine)
        
    }
}

// MARK: Parse Headers
extension Request {
    @inlinable
    public static func parseHeaders<T: InlineArrayProtocol>(buffer: T, offset: Int, headers: inout [String:String]) where T.Element == UInt8 {
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
                    let value:InlineArray<256, UInt8> = slice.slice(startIndex: colonIndex+2, endIndex: slice.endIndex, defaultValue: 0) //  skip the colon & adjacent space
                    headers[key.string()] = value.string()
                }
                //print("slice=\(slice.string())")
            }
        )
    }
}
extension Request {
    @inlinable
    public static func parseHeaders2<T: InlineArrayProtocol>(buffer: T, offset: Int, headers: inout [String:String]) where T.Element == UInt8 {
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
                    slice[j] = buffer.itemAt(index: i + j)
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
    @inlinable
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

extension Request {
    public struct Headers<let maxHeadersCount: Int>: Sendable {
        public var count:Int = 0
        public var values:InlineArray<maxHeadersCount, HeaderIndex>

        public init() {
            self.count = 0
            self.values = .init(repeating: Request.HeaderIndex(startIndex: 0, endIndex: 0))
        }

        @inlinable
        public var indices: Range<Int> {
            0..<count
        }

        @inlinable
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