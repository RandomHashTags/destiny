
#if CopyableInlineBytes

import DestinyEmbedded

public struct InlineBytes<let count: Int>: Sendable {
    public let value:InlineArray<count, UInt8>

    #if Inlinable
    @inlinable
    #endif
    public init(_ value: InlineArray<count, UInt8>) {
        self.value = value
    }

    #if Inlinable
    @inlinable
    #endif
    public var count: Int {
        value.count
    }
    
    #if Inlinable
    @inlinable
    #endif
    public func string() -> String {
        value.unsafeString()
    }

    #if Inlinable
    @inlinable
    #endif
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
    #if Inlinable
    @inlinable
    #endif
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
extension InlineBytes: ResponseBodyProtocol {}

extension InlineBytes: RouteResponderProtocol {
    #if Inlinable
    @inlinable
    #endif
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