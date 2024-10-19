//
//  RouteResponses.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import Foundation
import NIOCore

// MARK: StaticString
public struct RouteResponseStaticString : RouteResponseProtocol {
    let value:StaticString
    public init(_ value: StaticString) { self.value = value }
    public var isAsync : Bool { false }

    public func respond(to socket: borrowing any SocketProtocol & ~Copyable) throws {
        var err:Error? = nil
        value.withUTF8Buffer {
            do {
                try socket.write($0.baseAddress!, length: $0.count)
            } catch {
                err = error
            }
        }
        if let err:Error = err {
            throw err
        }
    }
    public func respondAsync(to socket: borrowing any SocketProtocol & ~Copyable) async throws {}
}

// MARK: String
public struct RouteResponseString : RouteResponseProtocol {
    let value:String
    public init(_ value: String) { self.value = value }
    public var isAsync : Bool { false }

    public func respond(to socket: borrowing any SocketProtocol & ~Copyable) throws {
        try value.utf8.withContiguousStorageIfAvailable {
            try socket.write($0.baseAddress!, length: $0.count)
        }
    }
    public func respondAsync(to socket: borrowing any SocketProtocol & ~Copyable) async throws {}
}

// MARK: UInt8Array
public struct RouteResponseUInt8Array : RouteResponseProtocol {
    let value:[UInt8]
    public init(_ value: [UInt8]) { self.value = value }
    public var isAsync : Bool { false }

    public func respond(to socket: borrowing any SocketProtocol & ~Copyable) throws {
        try value.withUnsafeBufferPointer {
            try socket.write($0.baseAddress!, length: $0.count)
        }
    }
    public func respondAsync(to socket: borrowing any SocketProtocol & ~Copyable) async throws {}
}

// MARK: UInt16Array
public struct RouteResponseUInt16Array : RouteResponseProtocol {
    let value:[UInt16]
    public init(_ value: [UInt16]) { self.value = value }
    public var isAsync : Bool { false }

    public func respond(to socket: borrowing any SocketProtocol & ~Copyable) throws {
        try value.withUnsafeBufferPointer {
            try socket.write($0.baseAddress!, length: $0.count)
        }
    }
    public func respondAsync(to socket: borrowing any SocketProtocol & ~Copyable) async throws {}
}

// MARK: ByteBuffer
public struct RouteResponseByteBuffer : RouteResponseProtocol {
    let value:ByteBuffer
    public init(_ value: ByteBuffer) { self.value = value }
    public var isAsync : Bool { false }

    public func respond(to socket: borrowing any SocketProtocol & ~Copyable) throws {
        try value.withUnsafeReadableBytes {
            try socket.write($0.baseAddress!, length: value.readableBytes)
        }
    }
    public func respondAsync(to socket: borrowing any SocketProtocol & ~Copyable) async throws {}
}

// MARK: Data
public struct RouteResponseData : RouteResponseProtocol {
    let value:Data
    public init(_ value: Data) { self.value = value }
    public var isAsync : Bool { false }

    public func respond(to socket: borrowing any SocketProtocol & ~Copyable) throws {
        try value.withUnsafeBytes {
            try socket.write($0.baseAddress!, length: value.count)
        }
    }
    public func respondAsync(to socket: borrowing any SocketProtocol & ~Copyable) async throws {}
}