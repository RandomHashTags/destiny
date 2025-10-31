
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

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension NonCopyableInlineBytes: ResponseBodyProtocol {}

extension NonCopyableInlineBytes: NonCopyableRouteResponderProtocol {
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try respond(socket: socket, completionHandler: completionHandler)
    }
}

#endif

#endif