
import DestinyBlueprint

extension ResponseBody {
    #if Inlinable
    @inlinable
    #endif
    public static func inlineBytes<let count: Int>(_ value: InlineArray<count, UInt8>) -> Self.InlineBytes<count> {
        Self.InlineBytes(.init(value))
    }

    public struct InlineBytes<let count: Int>: ResponseBodyProtocol, CustomStringConvertible {
        public let value:InlineByteArray<count>

        #if Inlinable
        @inlinable
        #endif
        public init(_ value: InlineArray<count, UInt8>) {
            self.value = .init(value)
        }

        #if Inlinable
        @inlinable
        #endif
        public init(_ value: InlineByteArray<count>) {
            self.value = value
        }

        public var description: String {
            "ResponseBody.InlineBytes(\(value))"
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
            value.string()
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