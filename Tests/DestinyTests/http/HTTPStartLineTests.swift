
import DestinyBlueprint
@testable import DestinyDefaults
import Testing

@Suite
struct HTTPStartLineTests {

    @Test
    func loadHTTPStartLine() throws {
        let method = "GET"
        let path = "/0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let request = "\(method) \(path) HTTP/1.1"

        var buffer = InlineArray<1024, UInt8>(repeating: 0)
        for i in 0..<request.count {
            buffer[i] = request[request.index(request.startIndex, offsetBy: i)].asciiValue ?? 0
        }
        let initialBuffer = InlineByteBuffer<1024>(buffer: buffer, endIndex: request.count)
        let requestLine = try HTTPRequestLine.load(buffer: initialBuffer)
        requestLine.method(buffer: buffer) {
            #expect($0.unsafeString() == method)
        }
        requestLine.path(buffer: buffer) {
            #expect($0.unsafeString() == path)
        }
    }
}