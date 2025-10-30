
import DestinyBlueprint
@testable import DestinyDefaults
@testable import DestinyEmbedded

struct TestHTTPSocket: FileDescriptor, ~Copyable {
    var fileDescriptor:Int32
    var _fileDescriptor:TestFileDescriptor

    init(fileDescriptor: Int32) {
        self.fileDescriptor = fileDescriptor
        _fileDescriptor = .init(fileDescriptor: fileDescriptor)
    }

    init(_fileDescriptor: TestFileDescriptor) {
        self.fileDescriptor = _fileDescriptor.fileDescriptor
        self._fileDescriptor = _fileDescriptor
    }

    func socketLocalAddress() -> String? {
        nil
    }
    func socketPeerAddress() -> String? {
        nil
    }

    func loadRequest() -> TestRequest {
        .init(fileDescriptor: _fileDescriptor, _request: .init())
    }

    func readBuffer(into baseAddress: UnsafeMutableRawPointer, length: Int, flags: Int32) throws(DestinyBlueprint.SocketError) -> Int {
        _fileDescriptor.readBuffer(into: baseAddress, length: length, flags: flags)
    }

    func socketReceive(baseAddress: UnsafeMutablePointer<UInt8>, length: Int, flags: Int32) -> Int {
        fileDescriptor.socketReceive(baseAddress: baseAddress, length: length, flags: flags)
    }

    func socketReceive(baseAddress: UnsafeMutableRawPointer, length: Int, flags: Int32) -> Int {
        fileDescriptor.socketReceive(baseAddress: baseAddress, length: length, flags: flags)
    }

    func socketSendMultiplatform(pointer: UnsafeRawPointer, length: Int) -> Int {
        fileDescriptor.socketSendMultiplatform(pointer: pointer, length: length)
    }
}

// MARK: Write
extension TestHTTPSocket {
    func writeBuffer(_ pointer: UnsafeRawPointer, length: Int) {
        _fileDescriptor.writeBuffer(pointer, length: length)
    }

    func writeBuffers3(
        _ b1: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b2: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b3: (buffer: UnsafePointer<UInt8>, bufferCount: Int)
    ) throws(SocketError) {
        try fileDescriptor.writeBuffers3(b1, b2, b3)
    }

    func writeBuffers4(
        _ b1: UnsafeBufferPointer<UInt8>,
        _ b2: UnsafeBufferPointer<UInt8>,
        _ b3: UnsafeBufferPointer<UInt8>,
        _ b4: UnsafeBufferPointer<UInt8>
    ) throws(SocketError) {
        try fileDescriptor.writeBuffers4(b1, b2, b3, b4)
    }

    func writeBuffers6(
        _ b1: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b2: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b3: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b4: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b5: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b6: (buffer: UnsafePointer<UInt8>, bufferCount: Int)
    ) throws(SocketError) {
        try fileDescriptor.writeBuffers6(b1, b2, b3, b4, b5, b6)
    }
}