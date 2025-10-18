
import DestinyBlueprint
@testable import DestinyDefaults

struct TestHTTPSocket: SocketProtocol, ~Copyable {
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

    func writeBuffer(_ pointer: UnsafeRawPointer, length: Int) {
        _fileDescriptor.writeBuffer(pointer, length: length)
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