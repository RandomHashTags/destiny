
#if RequestBodyStream

import DestinyBlueprint
import DestinyDefaults

// MARK: Body
extension AbstractHTTPRequest {
    /// - Throws: `any Error`
    package mutating func bodyStream<let count: Int>(
        fileDescriptor: some FileDescriptor,
        _ yield: (consuming InlineByteBuffer<count>) async throws -> Void
    ) async throws {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        try await storage.bodyStream(fileDescriptor: fileDescriptor, initialBuffer: initialBuffer!, yield)
    }
}

#endif