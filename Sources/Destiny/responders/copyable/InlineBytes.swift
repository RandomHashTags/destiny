
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
    ///   - socket: The socket.
    /// 
    /// - Throws: `ResponderError`
    public func respond(
        socket: borrowing some FileDescriptor & ~Copyable
    ) throws(ResponderError) {
        do throws(SocketError) {
            try value.write(to: socket)
        } catch {
            throw .socketError(error)
        }
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
    ) throws(ResponderError) {
        try respond(socket: request.fileDescriptor)
    }
}

#endif

#endif