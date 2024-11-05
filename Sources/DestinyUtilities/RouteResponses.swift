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
    public struct StaticString : StaticRouteResponseProtocol {
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
    public struct UnsafeBufferPointer : StaticRouteResponseProtocol {
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
    public struct String : StaticRouteResponseProtocol {
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
    public struct UInt8Array : StaticRouteResponseProtocol {
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
    public struct UInt16Array : StaticRouteResponseProtocol {
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
    public struct Data : StaticRouteResponseProtocol {
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

// MARK: Dynamic
extension RouteResponses {
    public struct Dynamic : DynamicRouteResponseProtocol {
        public let version:Swift.String
        public let method:HTTPRequest.Method
        public let path:[Swift.String]
        public let defaultResponse:DynamicResponseProtocol
        public let logic:@Sendable (borrowing Request, inout DynamicResponseProtocol) throws -> Void

        public init(
            version: Swift.String,
            method: HTTPRequest.Method,
            path: [Swift.String],
            defaultResponse: DynamicResponseProtocol,
            logic: @escaping (@Sendable (borrowing Request, inout DynamicResponseProtocol) throws -> Void)
        ) {
            self.version = version
            self.method = method
            self.path = path
            self.defaultResponse = defaultResponse
            self.logic = logic
        }

        @inlinable public var isAsync : Bool { false }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: borrowing Request, response: inout DynamicResponseProtocol) throws {
            try logic(request, &response)
            try response.response(version: request.version).utf8.withContiguousStorageIfAvailable {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }
        @inlinable public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: borrowing Request, response: inout DynamicResponseProtocol) async throws {}
    }
    public struct DynamicAsync : DynamicRouteResponseProtocol {
        public let method:HTTPRequest.Method
        public let path:[Swift.String]
        public let version:Swift.String
        public let defaultResponse:DynamicResponseProtocol
        public let logic:(@Sendable (borrowing Request, inout DynamicResponseProtocol) async throws -> Void)

        public init(
            method: HTTPRequest.Method,
            path: [Swift.String],
            version: Swift.String,
            defaultResponse: DynamicResponseProtocol,
            logic: @escaping (@Sendable (borrowing Request, inout DynamicResponseProtocol) async throws -> Void)
        ) {
            self.method = method
            self.path = path
            self.version = version
            self.defaultResponse = defaultResponse
            self.logic = logic
        }

        @inlinable public var isAsync : Bool { true }
        @inlinable public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: borrowing Request, response: inout DynamicResponseProtocol) throws {}

        @inlinable
        public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T, request: borrowing Request, response: inout DynamicResponseProtocol) async throws {
            try await logic(request, &response)
            try response.response(version: request.version).utf8.withContiguousStorageIfAvailable {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }
    }
}