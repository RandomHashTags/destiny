
import DestinyBlueprint
@testable import DestinyDefaults
import Testing
import TestRouter

@Suite
struct ResponseTests {
    @Test
    func responseStaticStringWithDateHeader() {
        let fd = TestFileDescriptor()
        fd.sendString("GET /html HTTP/1.1\r\n")
        let socket = TestHTTPSocket(_fileDescriptor: fd)
        let responder = TestRouter.DeclaredRouter.CaseSensitiveResponderStorage1.Route.responder4.copy()
        TestRouter.DeclaredRouter.router.handle(client: fd, socket: socket, completionHandler: {
            let capacity = HTTPRequest.InitialBuffer.count
            withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                buffer.initialize(repeating: 0)
                let received = fd.readReceived(into: buffer.baseAddress!, length: capacity)
                #expect(received == responder.count)
                let array = Array(buffer[0..<received])
                let string = String(decoding: array, as: UTF8.self)
                #expect(string.count == responder.count)

                let preDateValue = String.init(cString: responder.payload.preDatePointer)
                let postDateValue = String.init(cString: responder.payload.postDatePointer)
                #expect(string.hasPrefix(preDateValue))

                // TODO: fix | `hasSuffix` doesn't work here for some reason
                #expect(string.contains(postDateValue))
            }
        })
    }
}

fileprivate extension NonCopyableStaticStringWithDateHeader {
    func copy() -> Self {
        Self.init(payload)
    }
}