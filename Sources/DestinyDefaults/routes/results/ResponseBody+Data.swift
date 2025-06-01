
#if canImport(FoundationEssentials) || canImport(Foundation)
import DestinyBlueprint

#if canImport(FoundationEssentials)
import struct FoundationEssentials.Data
#else
import struct Foundation.Data
#endif

extension ResponseBody {
    @inlinable
    public static func data(_ value: Data) -> Self.FoundationData {
        Self.FoundationData(value)
    }
    public struct FoundationData: ResponseBodyProtocol {
        public let value:Data

        @inlinable
        public init(_ value: Data) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            "ResponseBody.data(\(value))"
        }

        public var responderDebugDescription: Swift.String {
            "RouteResponses.FoundationData(\(value))"
        }

        public func responderDebugDescription(_ input: Swift.String) -> Swift.String {
            Self(Data(input.utf8)).responderDebugDescription
        }

        public func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T) throws -> Swift.String{
            try responderDebugDescription(input.string(escapeLineBreak: false))
        }

        @inlinable
        public var count: Int {
            value.count
        }
        
        @inlinable
        public func string() -> Swift.String {
            .init(decoding: value, as: UTF8.self)
        }

        @inlinable
        public func bytes() -> [UInt8] {
            [UInt8](value)
        }

        @inlinable
        public func bytes(_ closure: (inout InlineVLArray<UInt8>) throws -> Void) rethrows {
            try InlineVLArray<UInt8>.create(collection: value, closure)
        }

        @inlinable public var hasDateHeader: Bool { false }
    }
}

#endif