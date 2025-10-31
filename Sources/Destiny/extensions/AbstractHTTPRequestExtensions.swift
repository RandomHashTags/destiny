
#if Protocols

// MARK: Conformance logic
extension AbstractHTTPRequest {
    /// - Throws: `SocketError`
    mutating func isMethod(fileDescriptor: some FileDescriptor, _ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return method.rawNameString() == storage.methodString(buffer: initialBuffer!)
    }
}

#endif