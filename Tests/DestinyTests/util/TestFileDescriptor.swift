
#if canImport(Android)
import Android
#elseif canImport(Bionic)
import Bionic
#elseif canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(WASILibc)
import WASILibc
#elseif canImport(Windows)
import Windows
#elseif canImport(WinSDK)
import WinSDK
#endif

@testable import Destiny

final class TestFileDescriptor: FileDescriptor, @unchecked Sendable {
    let fileDescriptor:Int32

    var sent:[[UInt8]] = []
    var received:[[UInt8]] = []

    init(fileDescriptor: Int32 = -1) {
        self.fileDescriptor = fileDescriptor
    }

    func sendString(_ string: String) {
        sent.append(.init(string.utf8))
    }

    func socketLocalAddress() -> String? {
        return nil
    }
    func socketPeerAddress() -> String? {
        return nil
    }

    func socketReceive(baseAddress: UnsafeMutablePointer<UInt8>, length: Int, flags: Int32) -> Int {
        0
    }

    func socketReceive(baseAddress: UnsafeMutableRawPointer, length: Int, flags: Int32) -> Int {
        0
    }

    func socketSendMultiplatform(pointer: UnsafeRawPointer, length: Int) -> Int {
        0
    }

    func close() {
    }
}

// MARK: Read
extension TestFileDescriptor {
    func readReceived(into baseAddress: UnsafeMutableRawPointer, length: Int) -> Int {
        return readMutating(into: baseAddress, length: length, array: &received)
    }

    func readBuffer(into baseAddress: UnsafeMutableRawPointer, length: Int, flags: Int32) -> Int {
        return readMutating(into: baseAddress, length: length, array: &sent)
    }
    func readBuffer(into buffer: UnsafeMutableBufferPointer<UInt8>, length: Int, flags: Int32) -> Int {
        return readMutating(into: buffer.baseAddress!, length: length, array: &sent)
    }
    func readBuffer() -> InlineByteBuffer<1024> {
        var buffer = InlineArray<1024, UInt8>(repeating: 0)
        var endIndex = 0
        let bufferCount = buffer.count
        var ms = buffer.mutableSpan
        ms.withUnsafeMutableBufferPointer {
            endIndex = readBuffer(into: $0, length: bufferCount, flags: 0)
        }
        return .init(buffer: buffer, endIndex: endIndex)
    }

    func readMutating(into baseAddress: UnsafeMutableRawPointer, length: Int, array: inout [[UInt8]]) -> Int {
        var read = 0
        while read < length, let buffer = array.first {
            var bufferIndex = 0
            while bufferIndex < buffer.count, bufferIndex < length {
                (baseAddress + read).initializeMemory(as: UInt8.self, to: buffer[bufferIndex])
                bufferIndex += 1
                read += 1
            }
            if bufferIndex == buffer.count {
                array.removeFirst()
            } else {
                array[0].removeFirst(bufferIndex)
            }
        }
        return read
    }
}

// MARK: Write
extension TestFileDescriptor {
    func writeBuffer(
        _ pointer: UnsafeRawPointer,
        length: Int
    ) {
        var buffer = Array(repeating: UInt8(0), count: length)
        for i in 0..<length {
            buffer[i] = pointer.advanced(by: i).load(as: UInt8.self)
        }
        received.append(buffer)
    }

    func writeBuffers3(
        _ b1: iovec,
        _ b2: iovec,
        _ b3: iovec
    ) throws(DestinyError) {
        appendBuffer(b1)
        appendBuffer(b2)
        appendBuffer(b3)
    }

    func writeBuffers4(
        _ b1: iovec,
        _ b2: UnsafeBufferPointer<UInt8>,
        _ b3: iovec,
        _ b4: UnsafeBufferPointer<UInt8>
    ) throws(DestinyError) {
        appendBuffer(b1)
        appendBuffer((b2.baseAddress!, b2.count))
        appendBuffer(b3)
        appendBuffer((b4.baseAddress!, b4.count))
    }

    func writeBuffers4(
        _ b1: UnsafeBufferPointer<UInt8>,
        _ b2: iovec,
        _ b3: UnsafeBufferPointer<UInt8>,
        _ b4: UnsafeBufferPointer<UInt8>
    ) throws(DestinyError) {
        appendBuffer((b1.baseAddress!, b1.count))
        appendBuffer(b2)
        appendBuffer((b3.baseAddress!, b3.count))
        appendBuffer((b4.baseAddress!, b4.count))
    }

    public func writeBuffers6(
        _ b1: iovec,
        _ b2: iovec,
        _ b3: iovec,
        _ b4: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b5: iovec,
        _ b6: (buffer: UnsafePointer<UInt8>, bufferCount: Int)
    ) throws(DestinyError) {
        appendBuffer(b1)
        appendBuffer(b2)
        appendBuffer(b3)
        appendBuffer(b4)
        appendBuffer(b5)
        appendBuffer(b6)
    }

    private func appendBuffer(_ b: iovec) {
        var array = Array<UInt8>(repeating: 0, count: b.iov_len)
        for i in 0..<b.iov_len {
            array[i] = b.iov_base!.loadUnaligned(fromByteOffset: i, as: UInt8.self)
        }
        received.append(array)
    }
    private func appendBuffer(_ b: (buffer: UnsafePointer<UInt8>, bufferCount: Int)) {
        var array = Array<UInt8>(repeating: 0, count: b.bufferCount)
        for i in 0..<b.bufferCount {
            array[i] = b.buffer[i]
        }
        received.append(array)
    }
}