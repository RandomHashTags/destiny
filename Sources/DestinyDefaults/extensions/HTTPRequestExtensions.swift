
#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension HTTPRequest {
    #if Inlinable
    @inlinable
    #endif
    public mutating func isMethod(_ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool {
        try abstractRequest.isMethod(fileDescriptor: fileDescriptor, method)
    }
}

#endif