
#if CopyableInlineBytes

public struct InlineBytes<let count: Int>: Sendable {
    public let value:InlineArray<count, UInt8>

    public init(_ value: InlineArray<count, UInt8>) {
        self.value = value
    }

    public var count: Int {
        value.count
    }
    
    public func string() -> String {
        value.unsafeString()
    }

    public func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) {
        value.write(to: buffer, at: &index)
    }
}

// MARK: Respond
extension InlineBytes {
    /// Writes a response to a file descriptor.
    /// 
    /// - Parameters:
    ///   - provider: Socket's provider.
    ///   - socket: The socket.
    /// 
    /// - Throws: `DestinyError`
    public func respond(
        provider: some SocketProvider,
        socket: borrowing some FileDescriptor & ~Copyable
    ) throws(DestinyError) {
        try value.write(to: socket)
        socket.flush(provider: provider)
    }
}

#if Protocols

// MARK: Conformances
extension InlineBytes: ResponseBodyProtocol {}

extension InlineBytes: RouteResponderProtocol {
    public func respond(
        provider: some SocketProvider,
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest
    ) throws(DestinyError) {
        try respond(provider: provider, socket: request.fileDescriptor)
    }
}

#endif

#endif