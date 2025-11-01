
#if CopyableBytes

public struct Bytes: Sendable {
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
extension Bytes {
    /// Writes a response to a file descriptor.
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
extension Bytes: ResponseBodyProtocol {}

extension Bytes: RouteResponderProtocol {
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