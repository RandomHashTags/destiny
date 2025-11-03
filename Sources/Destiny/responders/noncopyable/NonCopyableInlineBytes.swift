
#if NonCopyableInlineBytes

public struct NonCopyableInlineBytes<let count: Int>: Sendable, ~Copyable {
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
extension NonCopyableInlineBytes {
    /// Writes a response to a file descriptor.
    /// 
    /// - Parameters:
    ///   - socket: The socket.
    /// 
    /// - Throws: `DestinyError`
    public func respond(
        provider: some SocketProvider,
        socket: some FileDescriptor
    ) throws(DestinyError) {
        try value.write(to: socket)
        socket.flush(provider: provider)
    }
}

#if Protocols

// MARK: Conformances
extension NonCopyableInlineBytes: ResponseBodyProtocol {}

extension NonCopyableInlineBytes: NonCopyableRouteResponderProtocol {
    public func respond(
        provider: some SocketProvider,
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        request: inout HTTPRequest
    ) throws(DestinyError) {
        try respond(provider: provider, socket: request.fileDescriptor)
    }
}

#endif

#endif