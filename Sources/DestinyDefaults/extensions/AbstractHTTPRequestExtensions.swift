
#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformance logic
extension AbstractHTTPRequest {
    /// - Throws: `SocketError`
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func isMethod(fileDescriptor: some FileDescriptor, _ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return method.rawNameString() == storage.methodString(buffer: initialBuffer!)
    }
}

#endif