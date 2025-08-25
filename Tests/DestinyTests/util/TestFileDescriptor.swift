
import DestinyBlueprint

final class TestFileDescriptor: FileDescriptor, @unchecked Sendable {
    let fileDescriptor:Int32

    var sent:[[UInt8]] = []
    var received:[[UInt8]] = []

    init(fileDescriptor: Int32 = -1) {
        self.fileDescriptor = fileDescriptor
    }

    func readReceived(into baseAddress: UnsafeMutableRawPointer, length: Int) -> Int {
        return readMutating(into: baseAddress, length: length, array: &received)
    }

    func readBuffer(into baseAddress: UnsafeMutableRawPointer, length: Int, flags: Int32) -> Int {
        return readMutating(into: baseAddress, length: length, array: &sent)
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

    func writeBuffer(
        _ pointer: UnsafeRawPointer,
        length: Int
    ) {
        var buffer = Array(repeating: UInt8(0), count: length)
        for i in 0..<length {
            buffer[i] = pointer.advanced(by: i).load(as: UInt8.self)
        }
    }

    func writeBuffers<let count: Int>(_ buffers: InlineArray<count, UnsafeBufferPointer<UInt8>>) {
        for indice in buffers.indices {
            received.append(.init(buffers[indice]))
        }
    }

    func sendString(_ string: String) {
        sent.append(.init(string.utf8))
    }
}