//
//  RouteResponses.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import Foundation

public enum RouteResponses {
}

// MARK: StaticString
extension RouteResponses {
    public struct StaticString : RouteResponseProtocol {
        public let value:Swift.StaticString
        public init(_ value: Swift.StaticString) { self.value = value }
        @inlinable public var isAsync : Bool { false }

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
        public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try respond(to: socket)
        }
    }
}

// MARK: UnsafeBufferPointer
extension RouteResponses {
    public struct UnsafeBufferPointer : RouteResponseProtocol {
        public let value:Swift.UnsafeBufferPointer<UInt8>
        public init(_ value: Swift.UnsafeBufferPointer<UInt8>) { self.value = value }
        @inlinable public var isAsync : Bool { false }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
            try socket.writeBuffer(value.baseAddress!, length: value.count)
        }
        public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try respond(to: socket)
        }
    }
}

// MARK: String
extension RouteResponses {
    public struct String : RouteResponseProtocol {
        public let value:Swift.String
        public init(_ value: Swift.String) { self.value = value }
        @inlinable public var isAsync : Bool { false }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
            try value.utf8.withContiguousStorageIfAvailable {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }
        public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try respond(to: socket)
        }
    }
}

// MARK: UInt8Array
extension RouteResponses {
    public struct UInt8Array : RouteResponseProtocol {
        public let value:[UInt8]
        public init(_ value: [UInt8]) { self.value = value }
        @inlinable public var isAsync : Bool { false }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
            try value.withUnsafeBufferPointer {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }
        public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try respond(to: socket)
        }
    }
}

// MARK: UInt16Array
extension RouteResponses {
    public struct UInt16Array : RouteResponseProtocol {
        public let value:[UInt16]
        public init(_ value: [UInt16]) { self.value = value }
        @inlinable public var isAsync : Bool { false }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
            try value.withUnsafeBufferPointer {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }
        public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try respond(to: socket)
        }
    }
}


// MARK: Data
extension RouteResponses {
    public struct Data : RouteResponseProtocol {
        public let value:Foundation.Data
        public init(_ value: Foundation.Data) { self.value = value }
        @inlinable public var isAsync : Bool { false }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
            try value.withUnsafeBytes {
                try socket.writeBuffer($0.baseAddress!, length: value.count)
            }
        }
        public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try respond(to: socket)
        }
    }
}