
#if NonCopyableInlineBytes

import DestinyBlueprint

extension ResponseBody {
    #if Inlinable
    @inlinable
    #endif
    public static func nonCopyableInlineBytes<let count: Int>(_ value: InlineArray<count, UInt8>) -> Self.NonCopyableInlineBytes<count> {
        .init(value)
    }

    public struct NonCopyableInlineBytes<let count: Int>: ~Copyable {
        public let value:InlineArray<count, UInt8>

        #if Inlinable
        @inlinable
        #endif
        public init(_ value: InlineArray<count, UInt8>) {
            self.value = value
        }

        public var description: String {
            "ResponseBody.InlineBytes(\(value))" // TODO: fix
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
}

// MARK: Respond
extension ResponseBody.NonCopyableInlineBytes {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
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

// MARK: Conformances
extension ResponseBody.NonCopyableInlineBytes: ResponseBodyProtocol {}
extension ResponseBody.NonCopyableInlineBytes: NonCopyableStaticRouteResponderProtocol {}

#endif