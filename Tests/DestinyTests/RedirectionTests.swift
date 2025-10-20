
#if NonEmbedded

import DestinyEmbedded
import Testing

@Suite
struct RedirectionTests {

    @Test
    func redirectionResponse() {
        var status:HTTPResponseStatus.Code = 307 // temporary redirect
        var payload = HTTPResponseMessage.redirect(to: "html", status: status)
        var msg = payload.string(escapeLineBreak: false)
        #expect(msg == "HTTP/1.1 \(status)\r\nlocation: /html\r\n")

        status = 308 // permanent redirect
        payload = .redirect(to: "yippie", status: status)
        msg = payload.string(escapeLineBreak: false)
        #expect(msg == "HTTP/1.1 \(status)\r\nlocation: /yippie\r\n")

        payload.head.headers["Really"] = "rly"
        msg = payload.string(escapeLineBreak: false)
        #expect(msg == "HTTP/1.1 \(status)\r\nlocation: /yippie\r\nReally: rly\r\n")
    }
}

#endif