
import DestinyBlueprint

extension ResponseBody {
    #if Inlinable
    @inlinable
    #endif
    public static func bytes(_ value: [UInt8]) -> Self.Bytes {
        Self.Bytes(value)
    }
    public struct Bytes: ResponseBodyProtocol, CustomStringConvertible {
        public let value:[UInt8]

        #if Inlinable
        @inlinable
        #endif
        public init(_ value: [UInt8]) {
            self.value = value
        }

        public var description: String {
            "ResponseBody.Bytes(\(value))"
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

extension ResponseBody.Bytes: StaticRouteResponderProtocol {
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