//
//  Socket.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

#if canImport(Foundation)
import Foundation
#endif

// MARK: Socket
public struct Socket : SocketProtocol, ~Copyable {    
    public static let bufferLength:Int = 1024
    public let fileDescriptor:Int32

    public init(fileDescriptor: Int32) {
        self.fileDescriptor = fileDescriptor
        Self.noSigPipe(fileDescriptor: fileDescriptor)
    }
}

// MARK: Reading
extension Socket {
    /// Reads `scalarCount` characters and loads them into the target SIMD.
    @inlinable
    public func readLineSIMD<T : SIMD>(length: Int) throws -> (T, Int) where T.Scalar == UInt8 {
        var string:T = T()
        let read:Int = try withUnsafeMutableBytes(of: &string) { p in
            return try readSIMDBuffer(into: p.baseAddress!, length: length)
        }
        return (string, read)
    }

    @inlinable
    public func loadRequest() throws -> (RequestProtocol)? {
        var test:[SIMD64<UInt8>] = []
        test.reserveCapacity(16) // maximum of 1024 bytes; decent starting point
        while true {
            let (line, read):(SIMD64<UInt8>, Int) = try readLineSIMD(length: 64)
            if read <= 0 {
                break
            }
            test.append(line)
            if read < 64 {
                break
            }
        }
        if test.isEmpty {
            return nil
        }
        guard let request:Request = Request.init(tokens: test) else {
            throw SocketError.malformedRequest
        }
        return request
    }

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    public func readBuffer(into buffer: UnsafeMutableBufferPointer<UInt8>, length: Int, flags: Int32 = 0) throws -> Int {
        guard let baseAddress:UnsafeMutablePointer<UInt8> = buffer.baseAddress else { return 0 }
        return try readBuffer(into: baseAddress, length: length, flags: flags)
    }

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    public func readBuffer(into baseAddress: UnsafeMutablePointer<UInt8>, length: Int, flags: Int32 = 0) throws -> Int {
        var bytes_read:Int = 0
        while bytes_read < length {
            if Task.isCancelled { return 0 }
            let to_read:Int = min(Self.bufferLength, length - bytes_read)
            let read:Int = recv(fileDescriptor, baseAddress + bytes_read, to_read, flags)
            if read < 0 { // error
                try handleReadError()
                break
            } else if read == 0 { // end of file
                break
            }
            bytes_read += read
        }
        return bytes_read
    }

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    public func readBuffer(into baseAddress: UnsafeMutableRawPointer, length: Int, flags: Int32 = 0) throws -> Int {
        var bytes_read:Int = 0
        while bytes_read < length {
            if Task.isCancelled { return 0 }
            let to_read:Int = min(Self.bufferLength, length - bytes_read)
            let read:Int = recv(fileDescriptor, baseAddress + bytes_read, to_read, flags)
            if read < 0 { // error
                try handleReadError()
                break
            } else if read == 0 { // end of file
                break
            }
            bytes_read += read
        }
        return bytes_read
    }

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    public func readSIMDBuffer(into baseAddress: UnsafeMutableRawPointer, length: Int) throws -> Int {
        if Task.isCancelled { return 0 }
        let read:Int = recv(fileDescriptor, baseAddress, length, 0)
        if read < 0 { // error
            try handleReadError()
        }
        return read
    }

    @inlinable
    public func handleReadError() throws {
        if errno == EAGAIN || errno == EWOULDBLOCK {
            return
        }
        #if canImport(Foundation)
        throw SocketError.readBufferFailed(cerror())
        #else
        throw SocketError.readBufferFailed()
        #endif
    }
}

// MARK: Writing
extension Socket {
    @inlinable
    public func writeSIMD<T: SIMD>(_ simd: inout T) throws where T.Scalar: BinaryInteger {
        var err:Error? = nil
        withUnsafeBytes(of: simd) { p in
            do {
                try writeBuffer(p.baseAddress!, length: simd.leadingNonzeroByteCountSIMD)
            } catch {
                err = error
            }
        }
        if let err:Error = err {
            throw err
        }
    }
    @inlinable
    public func writeBuffer(_ pointer: UnsafeRawPointer, length: Int) throws {
        var sent:Int = 0
        while sent < length {
            if Task.isCancelled { return }
            #if os(Linux)
            let result:Int = send(fileDescriptor, pointer + sent, length - sent, Int32(MSG_NOSIGNAL))
            #else
            let result:Int = write(fileDescriptor, pointer + sent, length - sent)
            #endif
            if result <= 0 {
                #if canImport(Foundation)
                throw SocketError.writeFailed(cerror())
                #else
                throw SocketError.writeFailed("")
                #endif
            }
            sent += result
        }
    }
}