
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func chunkedDataWithDateHeader<Body: HTTPSocketWritable>(_ value: Body) -> HTTPChunkedDataWithDateHeader<Body> {
        .init(value)
    }

    public struct HTTPChunkedDataWithDateHeader<Body: HTTPSocketWritable>: ResponseBodyProtocol {
        public let value:Body

        public init(_ value: Body) {
            self.value = value
        }

        public var responderDebugDescription: String {
            "HTTPChunkedDataWithDateHeader(\"\(value))"
        }

        public func responderDebugDescription(_ input: String) -> String {
            HTTPChunkedDataWithDateHeader<String>(input).responderDebugDescription
        }

        public func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T) throws -> String {
            try responderDebugDescription(input.string(escapeLineBreak: true))
        }

        @inlinable public var count: Int { 0 }
        
        @inlinable
        public func string() -> String {
            var s = "\(value)"
            s.replace("\\\"", with: "\"") // TODO: fix
            return s
        }

        @inlinable public var hasDateHeader: Bool { true }

        @inlinable public var hasContentLength: Bool { false }

        @inlinable
        public func customInitializer(bodyString: String) -> String? {
            "\", body: " + bodyString
        }

        @inlinable
        public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) throws {
        }
    }
}