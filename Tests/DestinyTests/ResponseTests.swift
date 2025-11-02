
@testable import Destiny
import Testing
import TestRouter

@Suite
struct ResponseTests {
}

#if NonCopyableStaticStringWithDateHeader

extension ResponseTests {
    @Test
    func responseStaticStringWithDateHeader() throws(ResponderError) {
        let fd = TestFileDescriptor()
        fd.sendString("GET /html HTTP/1.1\r\n")
        let preDateValue = StaticString("HTTP/1.1 200\r\ndate: ") // 20
        // date placeholder
        let postDateValue = StaticString("\r\nserver: destiny\r\ncontent-type: text/plain\r\ncontent-length: 4\r\n\r\ntest") // 70
        let expectedPayload = preDateValue.description + HTTPDateFormat.placeholder + postDateValue.description
        // payload count == 119

        let responder = NonCopyableStaticStringWithDateHeader(
            preDateValue: preDateValue,
            postDateValue: postDateValue
        )
        try responder.respond(socket: fd)
        let capacity = HTTPRequest.InitialBuffer.count
        withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
            buffer.initialize(repeating: 0)
            let received = fd.readReceived(into: buffer.baseAddress!, length: capacity)
            #expect(received == 119)
            #expect(received == responder.count)

            let slice = buffer[0..<received]
            let string = String(cString: slice.base.baseAddress!)
            #expect(string == expectedPayload)
            #expect(string.hasPrefix(preDateValue.description))
            #expect(string.hasSuffix(postDateValue.description))
        }
    }
}

// MARK: Respond
extension NonCopyableStaticStringWithDateHeader {
    func respond(
        socket: borrowing some FileDescriptor & ~Copyable
    ) throws(ResponderError) {
        try payload.write(to: socket)
    }
}

extension NonCopyableDateHeaderPayload {
    func write(to socket: borrowing some FileDescriptor & ~Copyable) throws(ResponderError) {
        var err:SocketError? = nil
        var s = HTTPDateFormat.placeholder
        s.withUTF8 { datePointer in
            do throws(SocketError) {
                try socket.writeBuffers3(
                    (preDatePointer, preDatePointerCount),
                    (datePointer.baseAddress!, datePointer.count),
                    (postDatePointer, postDatePointerCount)
                )
            } catch {
                err = error
            }
        }
        if let err {
            throw .socketError(err)
        }
    }
}

#endif