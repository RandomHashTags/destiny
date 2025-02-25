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

public enum RouteResponses {
}

// MARK: StaticString
extension RouteResponses {
    public struct StaticString : StaticRouteResponderProtocol {
        public let value:Swift.StaticString

        public init(_ value: Swift.StaticString) {
            self.value = value
        }

        public var debugDescription : Swift.String {
            return "RouteResponses.StaticString(\"" + value.description + "\")"
        }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            var err:Error? = nil
            value.withUTF8Buffer {
                do {
                    try socket.writeBuffer($0.baseAddress!, length: $0.count)
                } catch {
                    err = error
                }
            }
            if let err:Error = err {
                throw err
            }
        }
    }
}

/*
// MARK: UnsafeBufferPointer
extension RouteResponses {
    public struct UnsafeBufferPointer : @unchecked Sendable, StaticRouteResponderProtocol {
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
    public struct String : StaticRouteResponderProtocol {
        public let value:Swift.String

        public init(_ value: Swift.String) {
            self.value = value
        }
        public init(_ response: HTTPMessage) {
            value = (try? response.string(escapeLineBreak: true)) ?? ""
        }

        public var debugDescription : Swift.String {
            return "RouteResponses.String(\"" + value + "\")"
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
    public struct UInt8Array : StaticRouteResponderProtocol {
        public let value:[UInt8]

        public init(_ value: [UInt8]) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            return "RouteResponses.UInt8Array(\(value))"
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
    public struct UInt16Array : StaticRouteResponderProtocol {
        public let value:[UInt16]

        public init(_ value: [UInt16]) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            return "RouteResponses.UInt16Array(\(value))"
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
    public struct FoundationData : StaticRouteResponderProtocol {
        public let value:Data

        public init(_ value: Data) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            return "RouteResponses.FoundationData(\(value))"
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