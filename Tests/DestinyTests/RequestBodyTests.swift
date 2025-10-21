
import DestinyBlueprint
@testable import DestinyDefaults
import Testing

@Suite
struct RequestBodyTests {
}

#if RequestBodyStream

// MARK: Stream
extension RequestBodyTests {
    @Test
    func requestBodyStreamExactCustomSize() async throws {
        let fd = TestFileDescriptor()
        let msg = "GET /html HTTP/1.1\r\nContent-Type: text/plain\r\nContent-Length: 10\r\n\r\n\((0..<10).map({ "\($0)" }).joined())"
        fd.sendString(msg)
        var request = AbstractHTTPRequest<1024>()
        try request.loadStorage(fileDescriptor: fd)
        try await request.bodyStream(fileDescriptor: fd) { (buffer: consuming InlineByteBuffer<10>) in
            for i in 0..<buffer.endIndex {
                let byte = buffer.buffer[i]
                if byte == 0 {
                    break
                }
                #expect(byte == 48 + i)
            }
        }
        #expect(request.storage._body?.totalRead == 10)
    }

    @Test
    func requestBodyStreamExactDefaultSize() async throws {
        let fd = TestFileDescriptor()
        let msg = "GET /html HTTP/1.1\r\nContent-Type: text/plain\r\nContent-Length: 10\r\n\r\n\((0..<10).map({ "\($0)" }).joined())"
        fd.sendString(msg)
        var request = AbstractHTTPRequest<1024>()
        try request.loadStorage(fileDescriptor: fd)
        try await request.bodyStream(fileDescriptor: fd) { (buffer: consuming HTTPRequest.InitialBuffer) in
            for i in 0..<buffer.endIndex {
                let byte = buffer.buffer[i]
                if byte == 0 {
                    break
                }
                #expect(byte == 48 + i)
            }
        }
        #expect(request.storage._body?.totalRead == 10)
    }
}

extension RequestBodyTests {
    @Test
    func requestBodyStreamHalfCustomSize() async throws {
        let fd = TestFileDescriptor()
        let msg = "GET /html HTTP/1.1\r\nContent-Type: text/plain\r\nContent-Length: 10\r\n\r\n\((0..<10).map({ "\($0)" }).joined())"
        fd.sendString(msg)
        var request = AbstractHTTPRequest<1024>()
        try request.loadStorage(fileDescriptor: fd)

        var bufferIndex = 0
        try await request.bodyStream(fileDescriptor: fd) { (buffer: consuming InlineByteBuffer<6>) in
            for i in 0..<buffer.endIndex {
                let byte = buffer.buffer[i]
                if byte == 0 {
                    break
                }
                let expected = 48 + i + (bufferIndex * 6)
                #expect(byte == expected, "bufferIndex=\(bufferIndex);byte=\(byte);expected=\(expected)")
            }
            bufferIndex += 1
        }
        #expect(bufferIndex == 2)
        #expect(request.storage._body?.totalRead == 10)
    }
}
#endif