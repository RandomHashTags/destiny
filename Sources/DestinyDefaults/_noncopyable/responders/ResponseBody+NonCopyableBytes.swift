
#if NonCopyableBytes

import DestinyEmbedded

extension ResponseBody {
    #if Inlinable
    @inlinable
    #endif
    public static func nonCopyableBytes(_ value: [UInt8]) -> Self.NonCopyableBytes {
        .init(value)
    }
    public struct NonCopyableBytes: Sendable, ~Copyable {
        public let value:[UInt8]

        #if Inlinable
        @inlinable
        #endif
        public init(_ value: [UInt8]) {
            self.value = value
        }

        public var description: String {
            "ResponseBody.NonCopyableBytes(\(value))"
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
}

// MARK: Respond
extension ResponseBody.NonCopyableBytes {
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
extension ResponseBody.NonCopyableBytes: ResponseBodyProtocol {}

extension ResponseBody.NonCopyableBytes: NonCopyableStaticRouteResponderProtocol {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try respond(socket: socket, completionHandler: completionHandler)
    }
}

#endif

#endif