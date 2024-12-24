//
//  RouteResponses.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import Foundation
import HTTPTypes

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
        public var isAsync : Bool { false }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
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

        @inlinable
        public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try respond(to: socket)
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
        @inlinable public var isAsync : Bool { false }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
            try socket.writeBuffer(value.baseAddress!, length: value.count)
        }

        @inlinable
        public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try respond(to: socket)
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

        public var debugDescription : Swift.String {
            return "RouteResponses.String(\"" + value + "\")"
        }

        @inlinable public var isAsync : Bool { false }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
            try value.utf8.withContiguousStorageIfAvailable {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }

        @inlinable
        public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try respond(to: socket)
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
        public var isAsync : Bool { false }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
            try value.withUnsafeBufferPointer {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }

        @inlinable
        public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try respond(to: socket)
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
        public var isAsync : Bool { false }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
            try value.withUnsafeBufferPointer {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }

        @inlinable
        public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try respond(to: socket)
        }
    }
}

// MARK: Data
extension RouteResponses {
    public struct Data : StaticRouteResponderProtocol {
        public let value:Foundation.Data

        public init(_ value: Foundation.Data) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            return "RouteResponses.Data(\(value))"
        }

        @inlinable
        public var isAsync : Bool { false }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
            try value.withUnsafeBytes {
                try socket.writeBuffer($0.baseAddress!, length: value.count)
            }
        }

        @inlinable
        public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try respond(to: socket)
        }
    }
}