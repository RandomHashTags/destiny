
#if CopyableBytes

import DestinyEmbedded

public struct Bytes: Sendable {
    public let value:[UInt8]

    #if Inlinable
    @inlinable
    #endif
    public init(_ value: [UInt8]) {
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
        .init(decoding: value, as: UTF8.self)
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
extension Bytes {
    /// Writes a response to a file descriptor.
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
extension Bytes: ResponseBodyProtocol {}

extension Bytes: StaticRouteResponderProtocol {
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