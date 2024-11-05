//
//  SocketProtocol.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation

// MARK: SocketProtocol
public protocol SocketProtocol : ~Copyable {
    static var bufferLength : Int { get }
    var fileDescriptor : Int32 { get }

    init(fileDescriptor: Int32)

    @inlinable func readLineSIMD<T: SIMD>() throws -> T where T.Scalar: BinaryInteger
    @inlinable func readHeaders() throws -> [String:String] // TODO: make faster (replace with a SIMD/StackString equivalent)

    @inlinable func readBuffer(into baseAddress: UnsafeMutablePointer<UInt8>, length: Int) throws -> Int
    @inlinable func writeBuffer(_ pointer: UnsafeRawPointer, length: Int) throws
}

public extension SocketProtocol where Self : ~Copyable {
    @inlinable
    static func noSigPipe(fileDescriptor: Int32) {
        #if os(Linux)
        #else
        var no_sig_pipe:Int32 = 0
        setsockopt(fileDescriptor, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, socklen_t(MemoryLayout<Int32>.size))
        #endif
    }
}

// MARK: SocketError
public enum SocketError : Error {
    case acceptFailed(String = cerror())
    case writeFailed(String = cerror())
    case readSingleByteFailed(String = cerror())
    case readBufferFailed(String = cerror())
    case invalidStatus(String = cerror())
    case closeFailure(String = cerror())
}