
#if RequestBodyStream

import DestinyBlueprint
import DestinyDefaults
import UnwrapArithmeticOperators

// MARK: Body
extension AbstractHTTPRequest._Storage {
    /// - Warning: `_headers` **MUST NOT** be `nil`!
    #if Inlinable
    @inlinable
    #endif
    mutating func bodyStream<let initialBufferCount: Int, let bufferCount: Int>(
        fileDescriptor: some FileDescriptor,
        initialBuffer: borrowing InlineByteBuffer<initialBufferCount>,
        _ yield: (consuming InlineByteBuffer<bufferCount>) async throws -> Void
    ) async throws {
        if _headers!._endIndex == nil {
            _headers!.load(fileDescriptor: fileDescriptor, initialBuffer: initialBuffer)
            var startIndex = _headers!._endIndex! +! 2
            if startIndex < initialBufferCount {
                // part of the request body is contained in the initial buffer
                var buffer = InlineArray<bufferCount, UInt8>(repeating: 0)
                var initialRequestBodyCount = initialBuffer.endIndex -! startIndex
                var remainingRequestBodyCount = initialRequestBodyCount
                loadBufferSlice(
                    initialBuffer: initialBuffer,
                    buffer: &buffer,
                    index: &startIndex,
                    initialRequestBodyCount: &remainingRequestBodyCount
                )
                try await yield(.init(buffer: buffer, endIndex: initialRequestBodyCount -! remainingRequestBodyCount))
                while remainingRequestBodyCount > 0 {
                    initialRequestBodyCount = remainingRequestBodyCount
                    loadBufferSlice(
                        initialBuffer: initialBuffer,
                        buffer: &buffer,
                        index: &startIndex,
                        initialRequestBodyCount: &remainingRequestBodyCount
                    )
                    try await yield(.init(buffer: buffer, endIndex: initialRequestBodyCount -! remainingRequestBodyCount))
                }
                if initialBuffer.endIndex != initialBufferCount {
                    // request body was completely within the initial buffer
                    return
                }
            }
        }
        try await _body!.stream(fileDescriptor: fileDescriptor, yield)
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func loadBufferSlice<let initialBufferCount: Int, let bufferCount: Int>(
        initialBuffer: borrowing InlineByteBuffer<initialBufferCount>,
        buffer: inout InlineArray<bufferCount, UInt8>,
        index: inout Int,
        initialRequestBodyCount: inout Int
    ) {
        let initialBufferSpan = initialBuffer.buffer.span
        var bufferMutableSpan = buffer.mutableSpan
        bufferMutableSpan.update(repeating: 0)
        let copied = min(bufferCount, initialRequestBodyCount)
        var i = 0
        while i < copied {
            bufferMutableSpan[unchecked: i] = initialBufferSpan[unchecked: index]
            i +=! 1
            index +=! 1
        }
        initialRequestBodyCount -=! copied
        _body!._totalRead +=! UInt64(copied)
    }
}

#endif