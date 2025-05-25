
#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

import DestinyBlueprint

public enum RouteResponses {
}

// MARK: StringWithDateHeader
extension RouteResponses {
    public struct StringWithDateHeader: StaticRouteResponderProtocol {
        public let value:Swift.StaticString

        public init(_ value: Swift.StaticString) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            return "RouteResponses.StringWithDateHeader(\"" + value.description + "\")"
        }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            var err:(any Error)? = nil
            value.withUTF8Buffer {
                guard let base = $0.baseAddress else { return }
                var baseAddress = base
                do {
                    // 20 = "HTTP/<v> <c>\r\n".count + "Date: ".count (14 + 6) where `<v>` is the HTTP Version and `<c>` is the HTTP Status Code
                    // write contents before the Date header value
                    try socket.writeBuffer(baseAddress, length: 20)
                    // advance the base address skipping the previous data + the count of the Date header value
                    baseAddress += 20 + HTTPDateFormat.InlineArrayResult.count
                    // write the Date header value
                    try HTTPDateFormat.shared.nowInlineArray.span.withUnsafeBufferPointer {
                        try socket.writeBuffer($0.baseAddress!, length: $0.count)
                    }
                    // write the contents after the Date header value
                    try socket.writeBuffer(baseAddress, length: $0.count - base.distance(to: baseAddress))
                } catch {
                    err = error
                }
            }
            if let err {
                throw err
            }
        }
    }
}

// MARK: StaticString
extension RouteResponses {
    public struct StaticString: StaticRouteResponderProtocol {
        public let value:Swift.StaticString

        public init(_ value: Swift.StaticString) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            "RouteResponses.StaticString(\"" + value.description + "\")"
        }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            var err:(any Error)? = nil
            value.withUTF8Buffer {
                do {
                    try socket.writeBuffer($0.baseAddress!, length: $0.count)
                } catch {
                    err = error
                }
            }
            if let err {
                throw err
            }
        }
    }
}

/*
// MARK: UnsafeBufferPointer
extension RouteResponses {
    public struct UnsafeBufferPointer: @unchecked Sendable, StaticRouteResponderProtocol {
        public let value:Swift.UnsafeBufferPointer<UInt8>
        public init(_ value: Swift.UnsafeBufferPointer<UInt8>) {
            self.value = value
        }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try socket.writeBuffer(value.baseAddress!, length: value.count)
        }
    }
}*/

// MARK: String
extension RouteResponses {
    public struct String: StaticRouteResponderProtocol {
        public let value:Swift.String

        public init(_ value: Swift.String) {
            self.value = value
        }
        public init(_ response: HTTPMessage, fromMacro: Bool) {
            value = (try? response.string(escapeLineBreak: true, fromMacro: fromMacro)) ?? ""
        }

        public var debugDescription: Swift.String {
            "RouteResponses.String(\"" + value + "\")"
        }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try value.utf8.withContiguousStorageIfAvailable {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }
    }
}

// MARK: MacroExpansion
extension RouteResponses {
    public struct MacroExpansion: StaticRouteResponderProtocol {
        public let value:Swift.String
        public let body:Swift.String

        public init(_ value: Swift.String, body: Swift.String) {
            self.value = value
            self.body = body
        }
        public init(_ response: HTTPMessage, fromMacro: Bool) {
            value = (try? response.string(escapeLineBreak: true, fromMacro: fromMacro)) ?? ""
            body = response.body?.debugDescription ?? ""
        }

        public var debugDescription: Swift.String {
            """
            RouteResponses.MacroExpansion(
                "\(value)",
                body: \(body)")
            )
            """
        }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            // TODO: improve performance | should we create a temporary buffer and correctly populate it so we only need to write to the socket once instead of 4 times?
            try value.utf8.withContiguousStorageIfAvailable {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
            var s = Swift.String(body.count)
            try s.withUTF8 {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
            try socket.writeCRLF(count: 2)
            try body.utf8.withContiguousStorageIfAvailable {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }
    }
}

// MARK: UInt8Array
extension RouteResponses {
    public struct UInt8Array: StaticRouteResponderProtocol {
        public let value:[UInt8]

        public init(_ value: [UInt8]) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            "RouteResponses.UInt8Array(\(value))"
        }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try value.withUnsafeBufferPointer {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }
    }
}

// MARK: UInt16Array
extension RouteResponses {
    public struct UInt16Array: StaticRouteResponderProtocol {
        public let value:[UInt16]

        public init(_ value: [UInt16]) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            "RouteResponses.UInt16Array(\(value))"
        }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try value.withUnsafeBufferPointer {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }
    }
}


#if canImport(FoundationEssentials) || canImport(Foundation)
// MARK: Foundation




// MARK: Data
extension RouteResponses {
    public struct FoundationData: StaticRouteResponderProtocol {
        public let value:Data

        public init(_ value: Data) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            "RouteResponses.FoundationData(\(value))"
        }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try value.withUnsafeBytes {
                try socket.writeBuffer($0.baseAddress!, length: value.count)
            }
        }
    }
}
#endif

// MARK: InlineArray
extension InlineArray where Element == UInt8 {
    @inlinable
    public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
        try span.withUnsafeBufferPointer {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }

    public var debugDescription: String {
        var s = "["
        for i in indices {
            s.append(Character(Unicode.Scalar(self[i])))
        }
        s += "]"
        return s
    }
}