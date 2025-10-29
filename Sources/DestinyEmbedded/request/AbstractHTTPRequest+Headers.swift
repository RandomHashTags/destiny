
#if RequestHeaders

import UnwrapArithmeticOperators

extension AbstractHTTPRequest {
    /// Default storage for an http request's headers.
    @usableFromInline
    package struct Headers: Sendable, ~Copyable {
        @usableFromInline
        let startIndex:Int

        @usableFromInline
        package var _endIndex:Int? = nil

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

// MARK: Load
extension AbstractHTTPRequest.Headers {
    /// Loads `_endIndex` and headers from a buffer.
    #if Inlinable
    @inlinable
    #endif
    package mutating func load<let count: Int>(
        buffer: borrowing InlineByteBuffer<count>
    ) {
        _endIndex = startIndex
        var index = startIndex
        var start = startIndex
        while index +! 3 < buffer.buffer.count {
            if buffer.buffer[unchecked: index] == .carriageReturn {
                // encountered \r
                if buffer.buffer[unchecked: index +! 1] == .lineFeed {
                    // encountered \r\n
                    if buffer.buffer[unchecked: index +! 2] == .carriageReturn
                    && buffer.buffer[unchecked: index +! 3] == .lineFeed {
                        // request body starts
                        _endIndex = index +! 2
                        return
                    }
                    let slice = buffer.buffer.unsafeString(startIndex: start, endIndex: index)
                    if let i = slice.firstIndex(of: ":") {
                        headers[slice[slice.startIndex..<i]] = slice[slice.index(i, offsetBy: 2)...]
                    }
                }
                index +=! 2
                start = index
            } else {
                index +=! 1
            }
        }
    }
}

#endif