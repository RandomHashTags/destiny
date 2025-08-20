
@testable import DestinyBlueprint
@testable import DestinyDefaults
import Testing

@Suite
struct HTTPStartLineTests {

    @Test
    func loadHTTPStartLine() throws {
        let method = "GET"
        let path = "/0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let request = "\(method) \(path) HTTP/1.1"
        var buffer = InlineByteArray<1024>(repeating: 0)
        for i in 0..<request.count {
            buffer.setItemAt(index: i, element: request[request.index(request.startIndex, offsetBy: i)].asciiValue ?? 0)
        }
        try HTTPStartLine.load(buffer: buffer) { startLine in
            #expect(startLine.method.string() == method)
            #expect(startLine.path.string() == path)
        }
    }
}