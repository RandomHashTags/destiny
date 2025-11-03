
#if NonCopyableBytes

public struct NonCopyableBytes: Sendable, ~Copyable {
    public let value:[UInt8]

    public init(_ value: [UInt8]) {
        self.value = value
    }

    public var count: Int {
        value.count
    }
    
    public func string() -> String {
        .init(decoding: value, as: UTF8.self)
    }

    public func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) {
        value.write(to: buffer, at: &index)
    }
}

// MARK: Respond
extension NonCopyableBytes {
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
extension NonCopyableBytes: ResponseBodyProtocol {}

extension NonCopyableBytes: NonCopyableRouteResponderProtocol {
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