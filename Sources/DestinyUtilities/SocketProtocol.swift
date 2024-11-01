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

    @inlinable
    func writeBuffer(_ pointer: UnsafeRawPointer, length: Int) throws
}

// MARK: SocketProtocol reading
public extension SocketProtocol where Self : ~Copyable {
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

    /// Reads multiple bytes and loads them into a SIMD vector.
    @inlinable
    func readBytesSIMD<T: SIMD>() throws -> T {
        var result:T = T()
        try withUnsafeMutablePointer(to: &result, { p in
            let bytes_read:Int = recv(fileDescriptor, p, T.scalarCount, 0)
            if bytes_read < 0 {
                throw SocketError.readSingleByteFailed()
            }
        })
        return result
    }

    @inlinable
    func readLine() throws -> String {
        var line:String = ""
        var index:UInt8 = 0
        while true {
            index = try self.readByte()
            if index == 10 {
                break
            } else if index == 13 {
                continue
            }
            line.append(Character(UnicodeScalar(index)))
        }
        return line
    }

    @inlinable
    func readHeaders() throws -> [String:String] { // TODO: make faster (replace with a SIMD/StackString equivalent)
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
    func readBuffer(into buffer: UnsafeMutableBufferPointer<UInt8>, length: Int) throws -> Int {
        guard let baseAddress:UnsafeMutablePointer<UInt8> = buffer.baseAddress else { return 0 }
        return try readBuffer(into: baseAddress, length: length)
    }
    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    func readBuffer(into baseAddress: UnsafeMutablePointer<UInt8>, length: Int) throws -> Int {
        var bytes_read:Int = 0
        while bytes_read < length {
            if Task.isCancelled { return 0 }
            let to_read:Int = min(Self.bufferLength, length - bytes_read)
            let read_bytes:Int = recv(fileDescriptor, baseAddress + bytes_read, to_read, 0)
            if read_bytes < 0 { // error
                throw SocketError.readBufferFailed()
            } else if read_bytes == 0 { // end of file
                break
            }
            bytes_read += read_bytes
        }
        return bytes_read
    }
}


// MARK: SocketProtocol writing
public extension SocketProtocol where Self : ~Copyable {
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

// MARK: Misc
public extension SocketProtocol where Self : ~Copyable {
    @inlinable
    func readLineSIMD<T: SIMD>() throws -> T where T.Scalar: BinaryInteger { // read just the method, path & http version
        var string:T = T()
        var i:Int = 0, char:UInt8 = 0
        while true {
            char = try readByte()
            if char == 10 || i == T.scalarCount {
                break
            } else if char == 13 {
                continue
            }
            string[i] = T.Scalar(char)
            i += 1
        }
        return string
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