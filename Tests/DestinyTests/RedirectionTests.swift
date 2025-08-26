
import DestinyDefaults
import Testing

@Suite
struct RedirectionTests {

    @Test
    func redirectionResponse() {
        var status = HTTPStandardResponseStatus.temporaryRedirect.code
        var payload = HTTPResponseMessage.redirect(to: "html", status: status)
        var msg = payload.string(escapeLineBreak: false)
        #expect(msg == "HTTP/1.1 \(status)\r\nLocation: /html\r\n")

        status = HTTPStandardResponseStatus.permanentRedirect.code
        payload = .redirect(to: "yippie", status: status)
        msg = payload.string(escapeLineBreak: false)
        #expect(msg == "HTTP/1.1 \(status)\r\nLocation: /yippie\r\n")

        payload.head.headers["Really"] = "rly"
        msg = payload.string(escapeLineBreak: false)
        #expect(msg == "HTTP/1.1 \(status)\r\nLocation: /yippie\r\nReally: rly\r\n")
    }
}