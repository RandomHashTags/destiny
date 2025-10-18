
#if NonEmbedded

import DestinyDefaults
import DestinyDefaultsNonEmbedded
import Testing

@Suite
struct RedirectionTests {

    @Test
    func redirectionResponse() {
        var status = HTTPStandardResponseStatus.temporaryRedirect.code
        var payload = HTTPResponseMessage.redirect(to: "html", status: status)
        var msg = payload.string(escapeLineBreak: false)
        #expect(msg == "HTTP/1.1 \(status)\r\nlocation: /html\r\n")

        status = HTTPStandardResponseStatus.permanentRedirect.code
        payload = .redirect(to: "yippie", status: status)
        msg = payload.string(escapeLineBreak: false)
        #expect(msg == "HTTP/1.1 \(status)\r\nlocation: /yippie\r\n")

        payload.head.headers["Really"] = "rly"
        msg = payload.string(escapeLineBreak: false)
        #expect(msg == "HTTP/1.1 \(status)\r\nlocation: /yippie\r\nReally: rly\r\n")
    }
}

#endif