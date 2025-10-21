
#if StaticRedirectionRoute

import DestinyEmbedded
import DestinyDefaults
import DestinyMacros
import Testing

@Suite
struct StaticRedirectionRouteTests {

    @Test
    func staticRedirectionRouteDefaults() {
        let route = StaticRedirectionRoute.init(
            method: HTTPRequestMethod(name: "GET"),
            from: ["old", "path"],
            to: ["newPath"]
        )
        #expect(route.version == .v1_1)
        #expect(route.isCaseSensitive)
        #expect(route.status == 301) // moved permanently
        #expect(route.method.rawNameString() == "GET")
        #expect(route.from == ["old", "path"])
        #expect(route.to == ["newPath"])
        #expect(route.fromStartLine() == "GET /old/path HTTP/1.1")

        let expected:String
        #if hasFeature(Embedded) || EMBEDDED
        expected = route.genericResponse().string(escapeLineBreak: true)
        #else
        expected = route.nonEmbeddedResponse().string(escapeLineBreak: true)
        #endif
        #expect(expected == #"HTTP/1.1 301\r\ndate: Thu, 01 Jan 1970 00:00:00 GMT\r\nlocation: /newPath\r\n"#)
    }

    @Test
    func staticRedirectionRouteCustomData() {
        let route = StaticRedirectionRoute.init(
            version: .v2_0,
            method: HTTPRequestMethod(name: "deLeTE"),
            status: 200, // ok
            from: ["old", "path"],
            isCaseSensitive: false,
            to: ["newPath", "agAin"]
        )
        #expect(route.version == .v2_0)
        #expect(!route.isCaseSensitive)
        #expect(route.status == 200)
        #expect(route.method.rawNameString() == "deLeTE")
        #expect(route.from == ["old", "path"])
        #expect(route.to == ["newPath", "agAin"])
        #expect(route.fromStartLine() == "deLeTE /old/path HTTP/2.0")

        let expected:String
        #if hasFeature(Embedded) || EMBEDDED
        expected = route.genericResponse().string(escapeLineBreak: true)
        #else
        expected = route.nonEmbeddedResponse().string(escapeLineBreak: true)
        #endif
        #expect(expected == #"HTTP/2.0 200\r\ndate: Thu, 01 Jan 1970 00:00:00 GMT\r\nlocation: /newPath/agAin\r\n"#)
    }

}


#endif