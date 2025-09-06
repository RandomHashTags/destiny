
import DestinyBlueprint
import DestinyDefaults
import Testing

@Suite
struct RequestBodyTests {
}

// MARK: Stream
extension RequestBodyTests {
    @Test
    func requestBodyStreamExactCustomSize() async throws {
        let fd = TestFileDescriptor()
        fd.sendString("\((0..<10).map({ "\($0)" }).joined())")
        var body = RequestBody(fileDescriptor: fd)
        try await body.stream { (buffer: InlineArray<11, UInt8>) in
            for i in 0..<buffer.count {
                let byte = buffer[i]
                if byte == 0 {
                    break
                }
                #expect(byte == 48 + i)
            }
        }
        #expect(body.totalRead == 10)
    }

    @Test
    func requestBodyStreamExactDefaultSize() async throws {
        let fd = TestFileDescriptor()
        fd.sendString("\((0..<10).map({ "\($0)" }).joined())")
        var body = RequestBody(fileDescriptor: fd)
        try await body.stream { buffer in
            for i in 0..<buffer.count {
                let byte = buffer[i]
                if byte == 0 {
                    break
                }
                #expect(byte == 48 + i)
            }
        }
        #expect(body.totalRead == 10)
    }
}

extension RequestBodyTests {
    @Test
    func requestBodyStreamHalfCustomSize() async throws {
        let fd = TestFileDescriptor()
        fd.sendString("\((0..<10).map({ "\($0)" }).joined())")
        var body = RequestBody(fileDescriptor: fd)
        var bufferIndex = 0
        try await body.stream { (buffer: InlineArray<6, UInt8>) in
            for i in 0..<buffer.count {
                let byte = buffer[i]
                if byte == 0 {
                    break
                }
                let expected = 48 + i + (bufferIndex * 6)
                #expect(byte == expected, "bufferIndex=\(bufferIndex);byte=\(byte);expected=\(expected)")
            }
            bufferIndex += 1
        }
        #expect(bufferIndex == 2)
        #expect(body.totalRead == 10)
    }
}
