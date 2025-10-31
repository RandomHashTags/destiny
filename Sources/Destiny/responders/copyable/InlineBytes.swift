
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
    ///   - completionHandler: Closure that should be called when the socket should be released.
    /// 
    /// - Throws: `ResponderError`
    public func respond(
        socket: some FileDescriptor,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        do throws(SocketError) {
            try value.write(to: socket)
        } catch {
            throw .socketError(error)
        }
        completionHandler()
    }
}

#if Protocols

// MARK: Conformances
extension InlineBytes: ResponseBodyProtocol {}

extension InlineBytes: RouteResponderProtocol {
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try respond(socket: socket, completionHandler: completionHandler)
    }
}

#endif

#endif