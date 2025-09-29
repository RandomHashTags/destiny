
#if Copyable

import DestinyBlueprint

extension ResponseBody {
    #if Inlinable
    @inlinable
    #endif
    public static func inlineBytes<let count: Int>(_ value: InlineArray<count, UInt8>) -> Self.InlineBytes<count> {
        Self.InlineBytes(value)
    }

    public struct InlineBytes<let count: Int>: ResponseBodyProtocol {
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
}

extension ResponseBody.InlineBytes: StaticRouteResponderProtocol {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
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

#endif