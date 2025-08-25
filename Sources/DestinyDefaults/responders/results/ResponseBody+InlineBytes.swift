
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func inlineBytes<let count: Int>(_ value: InlineArray<count, UInt8>) -> Self.InlineBytes<count> {
        Self.InlineBytes(.init(value))
    }

    public struct InlineBytes<let count: Int>: ResponseBodyProtocol, CustomStringConvertible {
        public let value:InlineByteArray<count>

        @inlinable
        public init(_ value: InlineArray<count, UInt8>) {
            self.value = .init(value)
        }

        @inlinable
        public init(_ value: InlineByteArray<count>) {
            self.value = value
        }

        public var description: String {
            "ResponseBody.InlineBytes(\(value))"
        }

        @inlinable
        public var count: Int {
            value.count
        }
        
        @inlinable
        public func string() -> String {
            value.string()
        }

        @inlinable
        public func write(
            to buffer: UnsafeMutableBufferPointer<UInt8>,
            at index: inout Int
        ) {
            value.write(to: buffer, at: &index)
        }
    }
}

extension ResponseBody.InlineBytes: StaticRouteResponderProtocol {
    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(SocketError) {
        try value.write(to: socket)
        completionHandler()
    }
}