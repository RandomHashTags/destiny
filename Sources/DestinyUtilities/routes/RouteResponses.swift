//
//  RouteResponses.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

import DestinyBlueprint

public enum RouteResponses {
}

// MARK: InlineArray
extension RouteResponses {
    public protocol InlineArrayProtocol: StaticRouteResponderProtocol {
    }
    public struct InlineArray<let count: Int>: InlineArrayProtocol {
        public let value:Swift.InlineArray<count, UInt8>

        public init(_ value: Swift.InlineArray<count, UInt8>) {
            self.value = value
        }

        @inlinable
        public var inlineArrayValueDescription: Swift.String {
            var s = "["
            for i in value.indices {
                s.append(Character(Unicode.Scalar(value[i])))
            }
            s += "]"
            return s
        }

        public var debugDescription: Swift.String {
            return "RouteResponses.InlineArray<\(count), UInt8>(" + inlineArrayValueDescription + ")"
        }

        /*@inlinable
        public mutating func write<T: DestinyBlueprint.InlineArrayProtocol>(value: T, at offset: Int = 0) where T.Element == UInt8 {
            var index = offset
            for i in value.indices {
                let targetIndex = offset + i
                if targetIndex >= count {
                    break
                }
                self.value.setItemAt(index: targetIndex, element: value.itemAt(index: i))
                index += 1
            }
        }*/

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try value.span.withUnsafeBufferPointer {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }
    }
}

// MARK: InlineArrayWithDateHeader
extension RouteResponses {
    public struct InlineArrayWithDateHeader<let count: Int>: InlineArrayProtocol {
        public let value:InlineArray<count>

        public init(_ value: InlineArray<count>) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            return "RouteResponses.InlineArrayWithDateHeader<\(count), UInt8>(" + value.inlineArrayValueDescription + ")"
        }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try value.value.span.withUnsafeBufferPointer {
                guard let base = $0.baseAddress else { return }
                var baseAddress = base
                // 22 = "HTTP/<v> <c>\r\n".count + "Date: ".count (16 + 6) where `<v>` is the HTTP Version and `<c>` is the HTTP Status Code
                // write contents before the Date header value
                try socket.writeBuffer(baseAddress, length: 22)
                // advance the base address skipping the previous data + the count of the Date header value
                baseAddress += 22 + HTTPDateFormat.InlineArrayResult.count
                // write the Date header value
                try HTTPDateFormat.shared.nowInlineArray.span.withUnsafeBufferPointer {
                    try socket.writeBuffer($0.baseAddress!, length: $0.count)
                }
                // write the contents after the Date header value
                try socket.writeBuffer(baseAddress, length: $0.count - base.distance(to: baseAddress))
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
        public init(_ response: HTTPMessage) {
            value = (try? response.string(escapeLineBreak: true)) ?? ""
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