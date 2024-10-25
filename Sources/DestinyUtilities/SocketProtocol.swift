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
    var closed : Bool { get set }
    @inlinable
    consuming func consume()

    @inlinable
    func writeBuffer(_ pointer: UnsafeRawPointer, length: Int) throws
}

public extension SocketProtocol where Self : ~Copyable {
    consuming func consume() {
        guard !closed else { return }
        closed = true
        close(fileDescriptor)
    }

    @inlinable
    func deinitalize() {
        guard !closed else { return }
        close(fileDescriptor)
    }
}

// MARK: SocketProtocol reading
public extension SocketProtocol where Self : ~Copyable {
    /// Reads 1 byte
    @inlinable
    func readByte() throws -> UInt8 {
        var result:UInt8 = 0
        let bytes_read:Int = read(fileDescriptor, &result, 1)
        if bytes_read < 1 {
            throw SocketError.readSingleByteFailed()
        }
        return result
    }
    /// Reads multiple bytes and loads them into an UInt8 array
    @inlinable
    func readBytes(length: Int) throws -> [UInt8] {
        return try [UInt8](unsafeUninitializedCapacity: length, initializingWith: { $1 = try readBuffer(into: &$0, length: length) })
    }


    /*@inlinable
    func readBytes<T: StackStringProtocol>(length: Int) throws -> T {

    }*/

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

    /*
    /// Reads multiple bytes and loads them into an UInt8 array
    @inlinable
    func read<T : Decodable>(decoder: Decoder) throws -> T {
        let length:Int = MemoryLayout<T>.size
        var buffer:UnsafeMutableBufferPointer<UInt8> = .allocate(capacity: length)
        try read(into: &buffer, length: length)
        return buffer.withUnsafeBytes {
            $0.withMemoryRebound(to: T.self, { _ in
                T.init(from: decoder)
            })
        }
    }*/

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    func readBuffer(into buffer: inout UnsafeMutableBufferPointer<UInt8>, length: Int) throws -> Int {
        var bytes_read:Int = 0
        guard let baseAddress:UnsafeMutablePointer<UInt8> = buffer.baseAddress else { return 0 }
        while bytes_read < length {
            let to_read:Int = min(Self.bufferLength, length - bytes_read)
            let read_bytes:Int = read(fileDescriptor, baseAddress + bytes_read, to_read)
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
        guard !closed else { return }
        var sent:Int = 0
        while sent < length {
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

// MARK: SocketError
public enum SocketError : Error {
    case acceptFailed(String = String(cString: strerror(errno)))
    case writeFailed(String = String(cString: strerror(errno)))
    case readSingleByteFailed(String = String(cString: strerror(errno)))
    case readBufferFailed(String = String(cString: strerror(errno)))
    case invalidStatus(String = String(cString: strerror(errno)))
}