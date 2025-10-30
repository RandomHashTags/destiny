
#if StaticMiddleware

import DestinyBlueprint
import Testing

@Suite
struct StaticMiddlewareTests {

    @Test
    func staticMiddlewareHandlesVersions() {
        var middleware = StaticMiddleware(handlesContentTypes: nil)
        #expect(middleware.handlesVersion(.v0_9))
        #expect(middleware.handlesVersion(.v1_0))
        #expect(middleware.handlesVersion(.v1_1))
        #expect(middleware.handlesVersion(.v1_2))
        #expect(middleware.handlesVersion(.v2_0))
        #expect(middleware.handlesVersion(.v3_0))

        middleware = StaticMiddleware(handlesVersions: [], handlesContentTypes: nil)
        #expect(!middleware.handlesVersion(.v0_9))
        #expect(!middleware.handlesVersion(.v1_0))
        #expect(!middleware.handlesVersion(.v1_1))
        #expect(!middleware.handlesVersion(.v1_2))
        #expect(!middleware.handlesVersion(.v2_0))
        #expect(!middleware.handlesVersion(.v3_0))

        middleware = StaticMiddleware(handlesVersions: [.v1_1], handlesContentTypes: nil)
        #expect(!middleware.handlesVersion(.v0_9))
        #expect(!middleware.handlesVersion(.v1_0))
        #expect(middleware.handlesVersion(.v1_1))
        #expect(!middleware.handlesVersion(.v1_2))
        #expect(!middleware.handlesVersion(.v2_0))
        #expect(!middleware.handlesVersion(.v3_0))
    }

    @Test
    func staticMiddlewareHandlesContentTypes() {
        var middleware = StaticMiddleware(handlesContentTypes: nil)
        #expect(middleware.handlesContentType(nil))
        #expect(middleware.handlesContentType("true"))
        #expect(middleware.handlesContentType("false"))

        middleware = StaticMiddleware(handlesContentTypes: [])
        #expect(!middleware.handlesContentType(nil))
        #expect(!middleware.handlesContentType("text/html"))
        #expect(!middleware.handlesContentType("text/plain"))

        middleware = StaticMiddleware(handlesContentTypes: ["text/plain"])
        #expect(!middleware.handlesContentType(nil))
        #expect(!middleware.handlesContentType("text/html"))
        #expect(middleware.handlesContentType("text/plain"))
    }

    @Test
    func staticMiddlewareHandlesStatuses() {
        var middleware = StaticMiddleware(handlesContentTypes: nil)
        #expect(middleware.handlesStatus(1))
        #expect(middleware.handlesStatus(.random(in: UInt16.min...UInt16.max)))

        middleware = StaticMiddleware(handlesStatuses: [], handlesContentTypes: nil)
        for i in HTTPResponseStatus.Code.min..<HTTPResponseStatus.Code.max {
            #expect(!middleware.handlesStatus(i))
        }

        middleware = StaticMiddleware(handlesStatuses: [501, 200], handlesContentTypes: nil)
        #expect(middleware.handlesStatus(200))
        #expect(!middleware.handlesStatus(201))
        #expect(!middleware.handlesStatus(500))
        #expect(middleware.handlesStatus(501))
        #expect(!middleware.handlesStatus(502))
    }

    @Test
    func staticMiddlewareHandlesMethods() {
        var middleware = StaticMiddleware(handlesContentTypes: nil)
        #expect(middleware.handlesMethod(HTTPRequestMethod("get")))
        #expect(middleware.handlesMethod(HTTPRequestMethod("womp")))

        middleware = StaticMiddleware(handlesMethods: [.init(name: "GET"), .init(name: "DELETE")], handlesContentTypes: nil)
        #expect(!middleware.handlesMethod(HTTPRequestMethod("get")))
        #expect(middleware.handlesMethod(HTTPRequestMethod("GET")))
        #expect(middleware.handlesMethod(HTTPRequestMethod("DELETE")))
        #expect(!middleware.handlesMethod(HTTPRequestMethod("DElETE")))
        #expect(!middleware.handlesMethod(HTTPRequestMethod("POST")))
    }
}

#endif