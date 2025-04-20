//
//  SocketProtocol.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

#if canImport(Darwin)
import Darwin
#endif

/// Core Socket protocol that handles incoming network requests.
public protocol SocketProtocol : ~Copyable {
    /// The maximum amount of bytes to read at a single time.
    static var bufferLength : Int { get }

    associatedtype ConcreteRequest:RequestProtocol
    
    /// The unique file descriptor the system assigns to this socket where communication between the server and client are handled.
    /// 
    /// - Warning: Do not close this file descriptor. It is closed automatically by the server.
    var fileDescriptor : Int32 { get }

    init(fileDescriptor: Int32)

    /// Reads a buffer from the socket.
    @inlinable func readBuffer(into baseAddress: UnsafeMutablePointer<UInt8>, length: Int, flags: Int32) throws -> Int

    @inlinable func readBuffer<let count: Int>() throws -> (InlineArray<count, UInt8>, Int)

    /// Writes a buffer to the socket.
    @inlinable func writeBuffer(_ pointer: UnsafeRawPointer, length: Int) throws

    /// Reads `scalarCount` characters and loads them into the target SIMD.
    @inlinable func readLineSIMD<T : SIMD>(length: Int) throws -> (simd: T, read: Int) where T.Scalar == UInt8 // TODO: remove
}

extension SocketProtocol where Self: ~Copyable {
    @inlinable
    public static func noSigPipe(fileDescriptor: Int32) {
        #if canImport(Darwin)
        var no_sig_pipe:Int32 = 0
        setsockopt(fileDescriptor, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, socklen_t(MemoryLayout<Int32>.size))
        #endif
    }
}