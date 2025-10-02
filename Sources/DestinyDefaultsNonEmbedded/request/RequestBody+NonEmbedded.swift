
#if RequestBodyStream

import DestinyBlueprint
import DestinyDefaults

// MARK: Stream
extension RequestBody {
    #if Inlinable
    @inlinable
    #endif
    public mutating func stream<let chunkSize: Int>(
        fileDescriptor: some FileDescriptor,
        //maximumSize: Int = 500_000,
        _ yield: (consuming InlineByteBuffer<chunkSize>) async throws -> Void
    ) async throws {
        var buffer = InlineArray<chunkSize, UInt8>(repeating: 0)
        try await stream(fileDescriptor: fileDescriptor,buffer: &buffer, yield)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func stream<let chunkSize: Int>(
        fileDescriptor: some FileDescriptor,
        buffer: inout InlineArray<chunkSize, UInt8>,
        _ yield: (consuming InlineByteBuffer<chunkSize>) async throws -> Void
    ) async throws {
        let asyncStream = AsyncThrowingStream<CopyableInlineBuffer<chunkSize>, any Error> { continuation in
            while true {
                var read = 0
                do throws(SocketError) {
                    read = try self.read(fileDescriptor: fileDescriptor, into: &buffer)
                } catch {
                    continuation.finish(throwing: error)
                    break
                }
                if read != chunkSize {
                    for i in stride(from: chunkSize-1, to: read-1, by: -1) {
                        buffer[unchecked: i] = 0
                    }
                    continuation.yield(.init(buffer: buffer, endIndex: read))
                    continuation.finish()
                    break
                } else {
                    continuation.yield(.init(buffer: buffer, endIndex: read))
                }
            }
        }
        for try await b in asyncStream {
            try await yield(b.noncopyable())
        }
    }
}

#endif