
import DestinyDefaults

#if canImport(DestinyBlueprint)
import DestinyBlueprint
#endif

#if canImport(DestinySwiftSyntax)
import DestinySwiftSyntax
#endif

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

#if canImport(Glibc)
import Glibc
#endif

#if Logging
import Logging
#endif

#if MediaTypes
import MediaTypes
#endif

package final class TestRouter {
    enum CustomError: Error {
        case yipyip
    }

    //#httpServer(routerType: "DeclaredRouter.CompiledHTTPRouter")

    // can't use in an extension because it errors with: "Circular reference"
    #declareRouter(
        routerSettings: .init(
            //dynamicResponsesAreGeneric: false,
            //protocolConformances: false,
            visibility: .package
        ),

        version: .v1_1,
        dynamicNotFoundResponder: nil,
        middleware: [
            StaticMiddleware(
                appliesContentType: nil,
                appliesHeaders: ["server":"destiny"],
                excludedRoutes: ["plaintext"]
            ),
            StaticMiddleware(
                handlesVersions: [.v1_0],
                appliesContentType: nil,
                appliesHeaders: ["version":"destiny1.0"]
            ),
            StaticMiddleware(
                handlesVersions: [.v1_1],
                appliesContentType: nil,
                appliesHeaders: ["version":"destiny1.1", "connection":"close"],
                appliesCookies: [
                    HTTPCookie(name: "cookie1", value: "yessir"),
                    HTTPCookie(name: "cookie2", value: "pogchamp")
                ],
                excludedRoutes: ["plaintext"]
            ),
            StaticMiddleware(
                handlesVersions: [.v2_0],
                appliesContentType: nil,
                appliesHeaders: ["version":"destiny2.0"]
            ),
            StaticMiddleware(
                handlesVersions: [.v3_0],
                appliesContentType: nil,
                appliesHeaders: ["version":"destiny3.0"]
            ),
            StaticMiddleware(
                handlesMethods: [HTTPStandardRequestMethod.get],
                handlesStatuses: [HTTPStandardResponseStatus.notImplemented.code],
                handlesMediaTypes: [MediaTypeText.html, MediaTypeApplication.json, MediaTypeText.plain],
                appliesStatus: HTTPStandardResponseStatus.ok.code,
                excludedRoutes: ["plaintext"]
            ),
            StaticMiddleware(
                handlesMethods: [HTTPStandardRequestMethod.get],
                appliesContentType: nil,
                appliesHeaders: ["you-get'd":"true"],
                excludedRoutes: ["plaintext"]
            ),
            StaticMiddleware(
                handlesMethods: [HTTPStandardRequestMethod.post],
                appliesContentType: nil,
                appliesHeaders: ["you-post'd":"true"]
            ),
            StaticMiddleware(
                handlesMethods: [HTTPStandardRequestMethod.get],
                handlesMediaTypes: [MediaTypeText.javascript],
                appliesStatus: HTTPStandardResponseStatus.badRequest.code
            ),
            DynamicCORSMiddleware(),
            DynamicDateMiddleware(),
            DynamicMiddleware({ request, response in
                guard try request.isMethod(HTTPRequestMethod(name: "GET")) else { return }
                #if canImport(FoundationEssentials) || canImport(Foundation)
                response.setHeader(key: "womp-womp", value: UUID().uuidString)
                #else
                response.setHeader(key: "womp-womp", value: String(UInt64.random(in: 0..<UInt64.max)))
                #endif
            })
        ],
        redirects: [
            StaticRedirectionRoute(method: HTTPStandardRequestMethod.get, from: ["legacyEndpoint"], to: ["newEndpoint"])
        ],
        routeGroups: [
            /*RouteGroup(
                endpoint: "grouped",
                staticMiddleware: [
                    StaticMiddleware(appliesHeaders: ["routergroup":"grouped"])
                ],
                Route.get(
                    path: ["hoopla"],
                    mediaType: MediaTypeText.plain,
                    body: NonCopyableStaticStringWithDateHeader("rly dud")
                ),
                Route.get(
                    path: ["HOOPLA"],
                    mediaType: MediaTypeText.plain,
                    handler: { _, response in
                        response.setBody("RLY DUD")
                    }
                )
            ),*/
        ],
        Route.get(
            path: ["newEndpoint"],
            mediaType: MediaTypeText.html,
            body: NonCopyableStaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>You've been redirected from /legacyEndpoint to here</h1></body></html>"#)
        ),
        Route.get(
            path: ["stream"],
            contentType: "text/plain",
            body: NonCopyableStreamWithDateHeader(AsyncHTTPChunkDataStream(["1liuesrhbgfler", "test2", "t3", "4"]))
        ),
        Route.get(
            path: ["expressionMacro"],
            mediaType: MediaTypeText.plain,
            body: ResponseBody.nonCopyableMacroExpansionWithDateHeader(#filePath)
        ),
        Route.post(
            path: ["post"],
            mediaType: MediaTypeApplication.json,
            body: NonCopyableStaticStringWithDateHeader(#"{"bing":"bonged"}"#)
        ),
        Route.get(
            path: ["bro?what=dude"],
            mediaType: MediaTypeApplication.json,
            body: #"{"bing":"bonged"}"#
        ),
        Route.get(
            path: ["html"],
            mediaType: MediaTypeText.html,
            body: NonCopyableStaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
        ),
        Route.get(
            path: ["SHOOP"],
            caseSensitive: false,
            mediaType: MediaTypeText.html,
            body: NonCopyableStaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
        ),
        Route.get(
            head: .init(version: .v2_0),
            path: ["html2"],
            mediaType: MediaTypeText.html,
            body: "<!DOCTYPE html><html><head><meta charset=\"\("UTF-8")\"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"
        ),
        Route.get(
            path: ["json"],
            mediaType: MediaTypeApplication.json,
            body: NonCopyableStaticStringWithDateHeader(#"{"this_outcome_was_inevitable_and_was_your_destiny":true}"#)
            //body: .json(StaticJSONResponse(this_outcome_was_inevitable_and_was_your_destiny: true)) // more work needed to get this working
        ),
        Route.get(
            path: ["txt"],
            mediaType: MediaTypeText.plain,
            body: NonCopyableStaticStringWithDateHeader("just a regular txt page; t'was your destiny")
        ),
        Route.get(
            path: ["string"],
            mediaType: MediaTypeText.plain,
            body: NonCopyableStaticStringWithDateHeader("""
            0123just a regular txt page; t'was your destiny
            y_up
            yup!!
            """)
        ),
        Route.get(
            path: ["inlineBytes"],
            mediaType: MediaTypeText.plain,
            body: NonCopyableInlineBytes([33, 34, 35, 36, 37, 38, 39, 40, 41, 42])
        ),
        Route.get(
            path: ["bytes"],
            mediaType: MediaTypeText.plain,
            body: NonCopyableBytes([33, 34, 35, 36, 37, 38, 39, 40, 41, 42])
        ),
        Route.get(
            path: ["bytes2"],
            mediaType: MediaTypeText.plain,
            body: NonCopyableBytes([.b, .r, .u, .h])
        ),
        Route.get(
            path: ["bytes3"],
            mediaType: MediaTypeText.plain,
            body: NonCopyableBytes([.b, .r, .u, .h])
        ),
        /*Route.get(
            path: ["error"],
            status: HTTPStandardResponseStatus.badRequest.code,
            mediaType: MediaTypeApplication.json,
            body: .error(CustomError.yipyip)
        ),*/
        Route.get( // https://www.techempower.com/benchmarks
            path: ["plaintext"],
            handler: { _, response in
                response.setStatusCode(200) // ok
                response.setHeader(key: "server", value: "Destiny")
                response.setBody("Hello World!")
            }
        ),
        Route.get(
            path: ["dynamicExpressionMacro"],
            handler: { _, response in
                response.setBody(#filePath)
            }
        ),
        Route.get(
            path: ["error2"],
            mediaType: MediaTypeText.plain,
            handler: { request, response in
                throw CustomError.yipyip
            }
        ),
        Route.get(
            path: ["dynamic"],
            mediaType: MediaTypeText.plain,
            handler: { request, response in
                let header = try request.header(forKey: "Host") ?? "nil"
                try response.setBody("host=\(header)")
            }
        ),
        Route.get(
            path: ["asyncDynamic"],
            mediaType: MediaTypeText.plain,
            handler: { request, response in
                response.setBody("asynced")
                try await Task.sleep(for: .seconds(3))
            }
        ),
        Route.get(
            head: .init(version: .v2_0),
            path: ["dynamic2"],
            mediaType: MediaTypeText.plain,
            handler: { request, response in
                #if canImport(FoundationEssentials) || canImport(Foundation)
                response.setBody(UUID().uuidString)
                #else
                response.setBody(String(UInt64.random(in: 0..<UInt64.max)))
                #endif
            }
        ),
        Route.get(
            path: ["dynamic", ":text"],
            mediaType: MediaTypeText.plain,
            handler: { request, response in
                response.setBody(response.parameter(at: 0))
            }
        ),
        Route.get(
            path: ["anydynamic", "*", "value"],
            mediaType: MediaTypeText.plain,
            handler: { request, response in
                response.setBody(response.parameter(at: 0))
            }
        ),
        /*Route.get(
            path: ["critters-{they}-bite"],
            mediaType: MediaTypeText.plain,
            body: NonCopyableStaticStringWithDateHeader("Cr1tters, THEY BITE!")
        ),*/
        Route.get(
            path: ["catchall", "**"],
            mediaType: MediaTypeText.plain,
            handler: { request, response in
                var s = "catchall/**;"
                response.yieldParameters { s += "\($0);" }
                response.setBody(s)
            }
        )
    )
}