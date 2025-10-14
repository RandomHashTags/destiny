
#if RequestBodyStream

import DestinyBlueprint
import DestinyDefaults

extension HTTPRequest {
    /// - Throws: `any Error`
    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyStream(
        _ yield: (consuming InitialBuffer) async throws -> Void
    ) async throws {
        try await abstractRequest.bodyStream(fileDescriptor: fileDescriptor, yield)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyStream<let count: Int>(
        _ yield: (consuming InlineByteBuffer<count>) async throws -> Void
    ) async throws {
        try await abstractRequest.bodyStream(fileDescriptor: fileDescriptor, yield)
    }
}

#endif