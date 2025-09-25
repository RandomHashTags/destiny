
import DestinyBlueprint
import DestinyDefaults

#if canImport(DestinySwiftSyntax)
import DestinySwiftSyntax
#endif

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
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
}

// MARK: Router
extension TestRouter {
    #declareRouter(
        routerSettings: .init(
            visibility: .package
        ),

        version: .v1_1,
        dynamicNotFoundResponder: nil,
        middleware: [
            StaticMiddleware(
                appliesContentType: nil,
                appliesHeaders: ["Server":"destiny"],
                excludedRoutes: ["plaintext"]
            ),
            StaticMiddleware(
                handlesVersions: [.v1_0],
                appliesContentType: nil,
                appliesHeaders: ["Version":"destiny1.0"]
            ),
            StaticMiddleware(
                handlesVersions: [.v1_1],
                appliesContentType: nil,
                appliesHeaders: ["Version":"destiny1.1", "Connection":"close"],
                appliesCookies: [HTTPCookie(name: "cookie1", value: "yessir"), HTTPCookie(name: "cookie2", value: "pogchamp")],
                excludedRoutes: ["plaintext"]
            ),
            StaticMiddleware(
                handlesVersions: [.v2_0],
                appliesContentType: nil,
                appliesHeaders: ["Version":"destiny2.0"]
            ),
            StaticMiddleware(
                handlesVersions: [.v3_0],
                appliesContentType: nil,
                appliesHeaders: ["Version":"destiny3.0"]
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
                appliesHeaders: ["You-GET'd":"true"],
                excludedRoutes: ["plaintext"]
            ),
            StaticMiddleware(
                handlesMethods: [HTTPStandardRequestMethod.post],
                appliesContentType: nil,
                appliesHeaders: ["You-POST'd":"true"]
            ),
            //StaticMiddleware(handlesMethods: [.get], handlesContentTypes: [.javascript], appliesStatus: .badRequest),
            DynamicCORSMiddleware(),
            DynamicDateMiddleware(),
            DynamicMiddleware({ request, response in
                #if RequestHeaders

                guard try request.isMethod(HTTPStandardRequestMethod.get) else { return }
                #if canImport(FoundationEssentials) || canImport(Foundation)
                response.setHeader(key: "Womp-Womp", value: UUID().uuidString)
                #else
                response.setHeader(key: "Womp-Womp", value: String(UInt64.random(in: 0..<UInt64.max)))
                #endif

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
                    StaticMiddleware(appliesHeaders: ["routerGroup":"grouped"])
                ],
                StaticRoute.get(
                    path: ["hoopla"],
                    mediaType: MediaTypeText.plain,
                    body: NonCopyableStaticStringWithDateHeader("rly dud")
                ),
                DynamicRoute.get(
                    path: ["HOOPLA"],
                    mediaType: MediaTypeText.plain,
                    handler: { _, response in
                        response.setBody("RLY DUD")
                    }
                )
            ),*/
        ],
        StaticRoute.get(
            path: ["newEndpoint"],
            mediaType: MediaTypeText.html,
            body: NonCopyableStaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>You've been redirected from /legacyEndpoint to here</h1></body></html>"#)
        ),
        StaticRoute.get(
            path: ["stream"],
            contentType: "text/plain",
            body: ResponseBody.nonCopyableStreamWithDateHeader(AsyncHTTPChunkDataStream(["1liuesrhbgfler", "test2", "t3", "4"]))
        ),
        StaticRoute.get(
            path: ["expressionMacro"],
            mediaType: MediaTypeText.plain,
            body: ResponseBody.nonCopyableMacroExpansionWithDateHeader(#filePath)
        ),
        StaticRoute.post(
            path: ["post"],
            mediaType: MediaTypeApplication.json,
            body: NonCopyableStaticStringWithDateHeader(#"{"bing":"bonged"}"#)
        ),
        StaticRoute.get(
            path: ["bro?what=dude"],
            mediaType: MediaTypeApplication.json,
            body: NonCopyableStaticStringWithDateHeader(#"{"bing":"bonged"}"#)
        ),
        StaticRoute.get(
            path: ["html"],
            mediaType: MediaTypeText.html,
            body: NonCopyableStaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
        ),
        StaticRoute.get(
            path: ["SHOOP"],
            caseSensitive: false,
            mediaType: MediaTypeText.html,
            body: NonCopyableStaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
        ),
        StaticRoute.get(
            version: .v2_0,
            path: ["html2"],
            mediaType: MediaTypeText.html,
            body: NonCopyableStaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
        ),
        StaticRoute.get(
            path: ["json"],
            mediaType: MediaTypeApplication.json,
            body: NonCopyableStaticStringWithDateHeader(#"{"this_outcome_was_inevitable_and_was_your_destiny":true}"#)
            //body: .json(StaticJSONResponse(this_outcome_was_inevitable_and_was_your_destiny: true)) // more work needed to get this working
        ),
        StaticRoute.get(
            path: ["txt"],
            mediaType: MediaTypeText.plain,
            body: NonCopyableStaticStringWithDateHeader("just a regular txt page; t'was your destiny")
        ),
        StaticRoute.get(
            path: ["inlineBytes"],
            mediaType: MediaTypeText.plain,
            body: ResponseBody.nonCopyableInlineBytes([
                .H, .T, .T, .P, .forwardSlash, 49, 46, 49, .space, 50, 48, 48, .carriageReturn, .lineFeed,
                .C, .o, .n, .t, .e, .n, .t, 45, .T, .y, .p, .e, .colon, .space, .t, .e, .x, .t, .forwardSlash, .p, .l, .a, .i, .n, .carriageReturn, .lineFeed,
                .C, .o, .n, .t, .e, .n, .t, 45, .L, .e, .n, .g, .t, .h, .colon, .space, 49, 48, .carriageReturn, .lineFeed, .carriageReturn, .lineFeed,
                33, 34, 35, 36, 37, 38, 39, 40, 41, 42
            ])
        ),
        StaticRoute.get(
            path: ["bytes"],
            mediaType: MediaTypeText.plain,
            body: ResponseBody.nonCopyableBytes([
                .H, .T, .T, .P, .forwardSlash, 49, 46, 49, .space, 50, 48, 48, .carriageReturn, .lineFeed,
                .C, .o, .n, .t, .e, .n, .t, 45, .T, .y, .p, .e, .colon, .space, .t, .e, .x, .t, .forwardSlash, .p, .l, .a, .i, .n, .carriageReturn, .lineFeed,
                .C, .o, .n, .t, .e, .n, .t, 45, .L, .e, .n, .g, .t, .h, .colon, .space, 49, 48, .carriageReturn, .lineFeed, .carriageReturn, .lineFeed,
                33, 34, 35, 36, 37, 38, 39, 40, 41, 42
            ])
        ),
        StaticRoute.get(
            path: ["bytes2"],
            mediaType: MediaTypeText.plain,
            body: ResponseBody.nonCopyableBytes([UInt8]("HTTP/1.1 200\r\nContent-Type: text/plain\r\nContent-Length: 4\r\n\r\nbruh".utf8))
        ),
        StaticRoute.get(
            path: ["bytes3"],
            mediaType: MediaTypeText.plain,
            body: ResponseBody.nonCopyableBytes(Array<UInt8>("HTTP/1.1 200\r\nContent-Type: text/plain\r\nContent-Length: 4\r\n\r\nbruh".utf8))
        ),
        /*StaticRoute.get(
            path: ["error"],
            status: HTTPStandardResponseStatus.badRequest.code,
            mediaType: MediaTypeApplication.json,
            body: .error(CustomError.yipyip)
        ),*/
        DynamicRoute.get( // https://www.techempower.com/benchmarks
            path: ["plaintext"],
            contentType: nil,
            handler: { _, response in
                response.setStatusCode(HTTPStandardResponseStatus.ok.code)

                #if RequestHeaders
                response.setHeader(key: "Server", value: "Destiny")
                #endif

                response.setBody("Hello World!")
            }
        ),
        DynamicRoute.get(
            path: ["dynamicExpressionMacro"],
            contentType: nil,
            handler: { _, response in
                response.setBody(#filePath)
            }
        ),
        DynamicRoute.get(
            path: ["error2"],
            mediaType: MediaTypeText.plain,
            handler: { request, response in
                throw CustomError.yipyip
            }
        ),
        DynamicRoute.get(
            path: ["dynamic"],
            mediaType: MediaTypeText.plain,
            handler: { request, response in
                #if RequestHeaders
                let header = try request.header(forKey: "Host") ?? "nil"
                #else
                let header = "nil"
                #endif

                try response.setBody("Host=\(header)")
            }
        ),
        DynamicRoute.get(
            path: ["asyncDynamic"],
            mediaType: MediaTypeText.plain,
            handler: { request, response in
                response.setBody("asynced")
                try await Task.sleep(for: .seconds(3))
            }
        ),
        DynamicRoute.get(
            version: .v2_0,
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
        DynamicRoute.get(
            path: ["dynamic", ":text"],
            mediaType: MediaTypeText.plain,
            handler: { request, response in
                response.setBody(response.parameter(at: 0))
            }
        ),
        DynamicRoute.get(
            path: ["anydynamic", "*", "value"],
            mediaType: MediaTypeText.plain,
            handler: { request, response in
                response.setBody(response.parameter(at: 0))
            }
        ),
        DynamicRoute.get(
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