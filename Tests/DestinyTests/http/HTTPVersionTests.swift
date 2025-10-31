
import Destiny
import Testing

@Suite
struct HTTPVersionTests {

    @Test
    func httpVersionInit() {
        let map = [
            UInt64(5211883372140310073): HTTPVersion.v0_9,
            5211883372140375600: HTTPVersion.v1_0,
            5211883372140375601: HTTPVersion.v1_1,
            5211883372140375602: HTTPVersion.v1_2,
            5211883372140441136: HTTPVersion.v2_0,
            5211883372140506672: HTTPVersion.v3_0,
        ]
        for (token, expected) in map {
            #expect(HTTPVersion(token: token) == expected)
        }

        var string = "HTTP/0.9"
        var versionUInt64 = string.utf8Span.span.bytes.unsafeLoadUnaligned(fromUncheckedByteOffset: 0, as: UInt64.self).bigEndian
        #expect(HTTPVersion(token: versionUInt64) == .v0_9, Comment(rawValue: "\(versionUInt64)"))

        string = "HTTP/1.0"
        versionUInt64 = string.utf8Span.span.bytes.unsafeLoadUnaligned(fromUncheckedByteOffset: 0, as: UInt64.self).bigEndian
        #expect(HTTPVersion(token: versionUInt64) == .v1_0, Comment(rawValue: "\(versionUInt64)"))

        string = "HTTP/1.1"
        versionUInt64 = string.utf8Span.span.bytes.unsafeLoadUnaligned(fromUncheckedByteOffset: 0, as: UInt64.self).bigEndian
        #expect(HTTPVersion(token: versionUInt64) == .v1_1, Comment(rawValue: "\(versionUInt64)"))

        string = "HTTP/1.2"
        versionUInt64 = string.utf8Span.span.bytes.unsafeLoadUnaligned(fromUncheckedByteOffset: 0, as: UInt64.self).bigEndian
        #expect(HTTPVersion(token: versionUInt64) == .v1_2, Comment(rawValue: "\(versionUInt64)"))

        string = "HTTP/2.0"
        versionUInt64 = string.utf8Span.span.bytes.unsafeLoadUnaligned(fromUncheckedByteOffset: 0, as: UInt64.self).bigEndian
        #expect(HTTPVersion(token: versionUInt64) == .v2_0, Comment(rawValue: "\(versionUInt64)"))

        string = "HTTP/3.0"
        versionUInt64 = string.utf8Span.span.bytes.unsafeLoadUnaligned(fromUncheckedByteOffset: 0, as: UInt64.self).bigEndian
        #expect(HTTPVersion(token: versionUInt64) == .v3_0, Comment(rawValue: "\(versionUInt64)"))
    }

    @Test
    func httpVersionString() {
        #expect(HTTPVersion.v0_9.string == "HTTP/0.9")
        #expect(HTTPVersion.v1_0.string == "HTTP/1.0")
        #expect(HTTPVersion.v1_1.string == "HTTP/1.1")
        #expect(HTTPVersion.v1_2.string == "HTTP/1.2")
        #expect(HTTPVersion.v2_0.string == "HTTP/2.0")
        #expect(HTTPVersion.v3_0.string == "HTTP/3.0")
    }

    @Test
    func httpVersionStaticString() {
        #expect(HTTPVersion.v0_9.staticString.description == "HTTP/0.9")
        #expect(HTTPVersion.v1_0.staticString.description == "HTTP/1.0")
        #expect(HTTPVersion.v1_1.staticString.description == "HTTP/1.1")
        #expect(HTTPVersion.v1_2.staticString.description == "HTTP/1.2")
        #expect(HTTPVersion.v2_0.staticString.description == "HTTP/2.0")
        #expect(HTTPVersion.v3_0.staticString.description == "HTTP/3.0")
    }
}