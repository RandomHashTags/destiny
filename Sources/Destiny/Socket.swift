//
//  Socket.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

// MARK: Socket
public struct Socket : SocketProtocol, ~Copyable {    
    public static let bufferLength:Int = 1024

    public typealias ConcreteRequest = Request

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
        var string = T()
        let read = try withUnsafeMutableBytes(of: &string) { p in
            return try readBuffer(into: p.baseAddress!, length: length)
        }
        return (string, read)
    }

    @inlinable
    public func readBuffer<let count: Int>() throws -> (InlineArray<count, UInt8>, Int) {
        var buffer = InlineArray<count, UInt8>.init(repeating: 0)
        let read = try withUnsafeMutableBytes(of: &buffer) { p in
            return try readBuffer(into: p.baseAddress!, length: count)
        }
        return (buffer, read)
    }

    @inlinable
    public func loadRequestInline() throws -> ConcreteRequest? {
        while true {
            let (buffer, read):(InlineArray<1024, UInt8>, Int) = try readBuffer()
            if read <= 0 {
                break
            }
            print("loadRequestLine;read=\(read)")
            // 32 = SPACE
            // 13 = \r
            // 10 = \n

            let startLine = try HTTPStartLine(buffer: buffer)
            print("startLine=\(startLine)")

            var skip:UInt8 = 0
            let nextLine:InlineArray<256, UInt8> = .init(repeating: 0)
            let _:InlineArray<256, UInt8>? = buffer.split(
                separators: 13, 10,
                defaultValue: 0,
                offset: startLine.endIndex + 1,
                yield: { slice in
                    if skip == 2 { // content
                    } else if slice == nextLine {
                        skip += 1
                    } else { // header
                    }
                    print("slice=\(slice.string())")
                }
            )
            if read < 1024 {
                break
            }
        }
        //loadRequestLine;read=512
        //slice=Host: 192.168.1.174:8080
        //slice=Connection: keep-alive
        //slice=Pragma: no-cache
        //slice=Cache-Control: no-cache
        //slice=Upgrade-Insecure-Requests: 1
        //slice=User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36
        //slice=Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        //slice=Accept-Encoding: gzip, deflate
        //slice=Accept-Language: en-US,en;q=0.9
        //slice=Cookie: cookie1=yessir; cookie2=pogchamp

        return nil // TODO: finish
        /*guard let request = ConcreteRequest.init(tokens: test) else {
            throw SocketError.malformedRequest()
        }
        return request*/
    }

    @inlinable
    public func loadRequest() throws -> ConcreteRequest? {
        //return try loadRequestInline()
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
        guard let request = ConcreteRequest.init(tokens: test) else {
            throw SocketError.malformedRequest()
        }
        return request
    }

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    public func readBuffer(into buffer: UnsafeMutableBufferPointer<UInt8>, length: Int, flags: Int32 = 0) throws -> Int {
        guard let baseAddress = buffer.baseAddress else { return 0 }
        return try readBuffer(into: baseAddress, length: length, flags: flags)
    }

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    public func readBuffer(into baseAddress: UnsafeMutablePointer<UInt8>, length: Int, flags: Int32 = 0) throws -> Int {
        var bytesRead = 0
        while bytesRead < length {
            if Task.isCancelled { return 0 }
            let toRead = min(Self.bufferLength, length - bytesRead)
            let read = receive(baseAddress + bytesRead, toRead, flags)
            if read < 0 { // error
                try handleReadError()
                break
            } else if read == 0 { // end of file
                break
            }
            bytesRead += read
        }
        return bytesRead
    }

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    public func readBuffer(into baseAddress: UnsafeMutableRawPointer, length: Int, flags: Int32 = 0) throws -> Int {
        var bytesRead = 0
        while bytesRead < length {
            if Task.isCancelled { return 0 }
            let toRead = min(Self.bufferLength, length - bytesRead)
            let read = receive(baseAddress + bytesRead, toRead, flags)
            if read < 0 { // error
                try handleReadError()
                break
            } else if read == 0 { // end of file
                break
            }
            bytesRead += read
        }
        return bytesRead
    }

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    public func readBuffer(into baseAddress: UnsafeMutableRawPointer, length: Int) throws -> Int {
        if Task.isCancelled { return 0 }
        let read = receive(baseAddress, length, 0)
        if read < 0 { // error
            try handleReadError()
        }
        return read
    }

    @inlinable
    public func handleReadError() throws {
        #if canImport(Glibc)
        if errno == EAGAIN || errno == EWOULDBLOCK {
            return
        }
        #endif
        throw SocketError.readBufferFailed()
    }
}

// MARK: Receive
extension Socket {
    @usableFromInline
    func receive(_ baseAddress: UnsafeMutablePointer<UInt8>, _ length: Int, _ flags: Int32 = 0) -> Int {
        return recv(fileDescriptor, baseAddress, length, flags)
    }
    @usableFromInline
    func receive(_ baseAddress: UnsafeMutableRawPointer, _ length: Int, _ flags: Int32 = 0) -> Int {
        return recv(fileDescriptor, baseAddress, length, flags)
    }
}

// MARK: Writing
extension Socket {
    @inlinable
    public func writeSIMD<T: SIMD>(_ simd: inout T) throws where T.Scalar: BinaryInteger {
        var err:(any Error)? = nil
        withUnsafeBytes(of: simd) { p in
            do {
                try writeBuffer(p.baseAddress!, length: simd.leadingNonzeroByteCountSIMD)
            } catch {
                err = error
            }
        }
        if let err {
            throw err
        }
    }
    @inlinable
    public func writeBuffer(_ pointer: UnsafeRawPointer, length: Int) throws {
        var sent = 0
        while sent < length {
            if Task.isCancelled { return }
            let result = send(pointer + sent, length - sent)
            if result <= 0 {
                throw SocketError.writeFailed()
            }
            sent += result
        }
    }
}

// MARK: Send
extension Socket {
    @usableFromInline
    func send(_ pointer: UnsafeRawPointer, _ length: Int) -> Int {
        #if canImport(Glibc)
        return SwiftGlibc.send(fileDescriptor, pointer, length, Int32(MSG_NOSIGNAL))
        #else
        return write(fileDescriptor, pointer, length)
        #endif
    }
}