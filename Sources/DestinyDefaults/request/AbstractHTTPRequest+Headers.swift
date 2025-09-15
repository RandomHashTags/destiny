
import DestinyBlueprint

extension AbstractHTTPRequest {
    @usableFromInline
    package struct Headers: Sendable, ~Copyable {
        @usableFromInline
        let startIndex:Int

        @usableFromInline
        var _endIndex:Int? = nil

        @usableFromInline
        var headers:[Substring:Substring] = [:]

        #if Inlinable
        @inlinable
        #endif
        init(startIndex: Int) {
            self.startIndex = startIndex
        }

        #if Inlinable
        @inlinable
        #endif
        #if InlineAlways
        @inline(__always)
        #endif
        subscript(key: Substring) -> Substring? {
            _read { yield headers[key] }
            _modify { yield &headers[key] }
        }
    }
}

extension AbstractHTTPRequest.Headers {
    /// Loads `headers` and `_endIndex`.
    #if Inlinable
    @inlinable
    #endif
    mutating func load<let count: Int>(
        fileDescriptor: some FileDescriptor,
        initialBuffer: borrowing InlineByteBuffer<count>
    ) {
        // TODO: optimize?
        _endIndex = startIndex
        let string = initialBuffer.buffer.unsafeString(offset: startIndex)
        let slices = string.split(separator: "\r\n", omittingEmptySubsequences: false)
        for slice in slices {
            if slice.isEmpty { // request body starts
                break
            }
            if let i = slice.firstIndex(of: ":") {
                headers[slice[slice.startIndex..<i]] = slice[slice.index(i, offsetBy: 2)...]
            }
            _endIndex! += slice.utf8Span.count + 2
        }
    }
}