//
//  RouteResponses.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import Foundation

// MARK: StaticString
public struct RouteResponseStaticString : RouteResponseProtocol {
    public let value:StaticString
    public init(_ value: StaticString) { self.value = value }
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
    @inlinable public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {}
}

// MARK: StaticStringPointer
public struct RouteResponseUnsafeBufferPointer : RouteResponseProtocol {
    public let value:UnsafeBufferPointer<UInt8>
    public init(_ value: UnsafeBufferPointer<UInt8>) { self.value = value }
    @inlinable public var isAsync : Bool { false }

    @inlinable
    public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
        try socket.writeBuffer(value.baseAddress!, length: value.count)
    }
    @inlinable public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {}
}

// MARK: String
public struct RouteResponseString : RouteResponseProtocol {
    public let value:String
    public init(_ value: String) { self.value = value }
    @inlinable public var isAsync : Bool { false }

    @inlinable
    public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
        try value.utf8.withContiguousStorageIfAvailable {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }
    @inlinable public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {}
}

// MARK: UInt8Array
public struct RouteResponseUInt8Array : RouteResponseProtocol {
    public let value:[UInt8]
    public init(_ value: [UInt8]) { self.value = value }
    @inlinable public var isAsync : Bool { false }

    @inlinable
    public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
        try value.withUnsafeBufferPointer {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }
    public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {}
}

// MARK: UInt16Array
public struct RouteResponseUInt16Array : RouteResponseProtocol {
    public let value:[UInt16]
    public init(_ value: [UInt16]) { self.value = value }
    @inlinable public var isAsync : Bool { false }

    @inlinable
    public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
        try value.withUnsafeBufferPointer {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }
    @inlinable public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {}
}

// MARK: Data
public struct RouteResponseData : RouteResponseProtocol {
    public let value:Data
    public init(_ value: Data) { self.value = value }
    @inlinable public var isAsync : Bool { false }

    @inlinable
    public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) throws {
        try value.withUnsafeBytes {
            try socket.writeBuffer($0.baseAddress!, length: value.count)
        }
    }
    @inlinable public func respondAsync<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {}
}