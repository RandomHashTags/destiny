//
//  Socket.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import DestinyUtilities
import Foundation

// MARK: Socket
public struct Socket : SocketProtocol, ~Copyable {
    public static let bufferLength:Int = 1024
    public let fileDescriptor:Int32

    public init(fileDescriptor: Int32) {
        self.fileDescriptor = fileDescriptor
        Self.noSigPipe(fileDescriptor: fileDescriptor)
    }
}
// MARK: Socket reading
public extension Socket {
    /// Reads 1 byte
    @inlinable
    func readByte() throws -> UInt8 {
        var result:UInt8 = 0
        let bytes_read:Int = recv(fileDescriptor, &result, 1, 0)
        if bytes_read < 0 {
            throw SocketError.readSingleByteFailed()
        }
        return result
    }

    @inlinable
    func readLine() throws -> String {
        var line:String = ""
        var index:UInt8 = 0
        while true {
            index = try self.readByte()
            if index == 10 { // line feed (\n)
                break
            } else if index == 13 { // carriage return (\r)
                continue
            }
            line.append(Character(UnicodeScalar(index)))
        }
        return line
    }

    /// Reads `scalarCount` characters and loads them into the target SIMD.
    @inlinable
    func readLineSIMD<T : SIMD>(length: Int) throws -> (T, Int) where T.Scalar == UInt8 { // read just the method, path & http version
        var string:T = T()
        let read:Int = try withUnsafeMutableBytes(of: &string) { p in
            return try readSIMDBuffer(into: p.baseAddress!, length: length)
        }
        return (string, read)
    }

    func loadRequest() throws -> Request {
        var test:[SIMD64<UInt8>] = []
        test.reserveCapacity(16) // maximum of 1024 bytes; decent starting point
        while true {
            let (line, read):(SIMD64<UInt8>, Int) = try readLineSIMD(length: 64)
            if read == 0 {
                break
            }
            test.append(line)
            if read < 64 {
                break
            }
        }
        guard let request:Request = Request(tokens: test) else {
            throw SocketError.malformedRequest
        }
        return request 
    }

    @inlinable
    func readHeaders() throws -> [String:String] {
        var headers:[String:String] = [:]
        while case let line:String = try readLine(), !line.isEmpty {
            let values:[Substring] = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            if let header:Substring = values.first, let value:Substring = values.last {
                headers[header.lowercased()] = value.trimmingCharacters(in: .whitespaces)
            }
        }
        return headers
    }

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    func readBuffer(into buffer: UnsafeMutableBufferPointer<UInt8>, length: Int, flags: Int32 = 0) throws -> Int {
        guard let baseAddress:UnsafeMutablePointer<UInt8> = buffer.baseAddress else { return 0 }
        return try readBuffer(into: baseAddress, length: length, flags: flags)
    }

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    func readBuffer(into baseAddress: UnsafeMutablePointer<UInt8>, length: Int, flags: Int32 = 0) throws -> Int {
        var bytes_read:Int = 0
        while bytes_read < length {
            if Task.isCancelled { return 0 }
            let to_read:Int = min(Self.bufferLength, length - bytes_read)
            let read_bytes:Int = recv(fileDescriptor, baseAddress + bytes_read, to_read, flags)
            if read_bytes < 0 { // error
                throw SocketError.readBufferFailed()
            } else if read_bytes == 0 { // end of file
                break
            }
            bytes_read += read_bytes
        }
        return bytes_read
    }
    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    func readBuffer(into baseAddress: UnsafeMutableRawPointer, length: Int, flags: Int32 = 0) throws -> Int {
        var bytes_read:Int = 0
        while bytes_read < length {
            if Task.isCancelled { return 0 }
            let to_read:Int = min(Self.bufferLength, length - bytes_read)
            let read_bytes:Int = recv(fileDescriptor, baseAddress + bytes_read, to_read, flags)
            if read_bytes < 0 { // error
                throw SocketError.readBufferFailed()
            } else if read_bytes == 0 { // end of file
                break
            }
            bytes_read += read_bytes
        }
        return bytes_read
    }

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    func readSIMDBuffer(into baseAddress: UnsafeMutableRawPointer, length: Int) throws -> Int {
        if Task.isCancelled { return 0 }
        let read_bytes:Int = recv(fileDescriptor, baseAddress, length, 0)
        if read_bytes < 0 { // error
            throw SocketError.readBufferFailed()
        }
        return read_bytes
    }
}

// MARK: Socket writing
public extension Socket {
    @inlinable
    func writeSIMD<T: SIMD>(_ simd: inout T) throws where T.Scalar: BinaryInteger {
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
    func writeBuffer(_ pointer: UnsafeRawPointer, length: Int) throws {
        var sent:Int = 0
        while sent < length {
            if Task.isCancelled { return }
            #if os(Linux)
            let result:Int = send(fileDescriptor, pointer + sent, length - sent, Int32(MSG_NOSIGNAL))
            #else
            let result:Int = write(fileDescriptor, pointer + sent, length - sent)
            #endif
            if result <= 0 { throw SocketError.writeFailed() }
            sent += result
        }
    }
}