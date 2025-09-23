
import DestinyBlueprint
import DestinyDefaults
import DestinySwiftSyntax // only used for the macro; comment-out here and Package.swift to save binary size when expanded
import HTTPMediaTypes
import Logging

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
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
            copyable: false,
            visibility: .package
        ),

        version: .v1_1,
        dynamicNotFoundResponder: nil,
        middleware: [
            StaticMiddleware(
                appliesHeaders: ["Server":"destiny"],
                excludedRoutes: ["plaintext"]
            ),
            StaticMiddleware(
                handlesVersions: [.v1_0],
                appliesHeaders: ["Version":"destiny1.0"]
            ),
            StaticMiddleware(
                handlesVersions: [.v1_1],
                appliesHeaders: ["Version":"destiny1.1", "Connection":"close"],
                appliesCookies: [HTTPCookie(name: "cookie1", value: "yessir"), HTTPCookie(name: "cookie2", value: "pogchamp")],
                excludedRoutes: ["plaintext"]
            ),
            StaticMiddleware(handlesVersions: [.v2_0], appliesHeaders: ["Version":"destiny2.0"]),
            StaticMiddleware(handlesVersions: [.v3_0], appliesHeaders: ["Version":"destiny3.0"]),
            StaticMiddleware(
                handlesMethods: [HTTPStandardRequestMethod.get],
                handlesStatuses: [HTTPStandardResponseStatus.notImplemented.code],
                handlesContentTypes: [HTTPMediaTypeText.html, HTTPMediaTypeApplication.json, HTTPMediaTypeText.plain],
                appliesStatus: HTTPStandardResponseStatus.ok.code,
                excludedRoutes: ["plaintext"]
            ),
            StaticMiddleware(
                handlesMethods: [HTTPStandardRequestMethod.get],
                appliesHeaders: ["You-GET'd":"true"],
                excludedRoutes: ["plaintext"]
            ),
            StaticMiddleware(handlesMethods: [HTTPStandardRequestMethod.post], appliesHeaders: ["You-POST'd":"true"]),
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
                    contentType: HTTPMediaTypeText.plain,
                    body: NonCopyableStaticStringWithDateHeader("rly dud")
                ),
                DynamicRoute.get(
                    path: ["HOOPLA"],
                    contentType: HTTPMediaTypeText.plain,
                    handler: { _, response in
                        response.setBody("RLY DUD")
                    }
                )
            ),*/
        ],
        StaticRoute.get(
            path: ["newEndpoint"],
            contentType: HTTPMediaTypeText.html,
            body: NonCopyableStaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>You've been redirected from /legacyEndpoint to here</h1></body></html>"#)
        ),
        StaticRoute.get(
            path: ["stream"],
            contentType: HTTPMediaTypeText.plain,
            body: ResponseBody.nonCopyableStreamWithDateHeader(AsyncHTTPChunkDataStream(["1liuesrhbgfler", "test2", "t3", "4"]))
        ),
        StaticRoute.get(
            path: ["expressionMacro"],
            contentType: HTTPMediaTypeText.plain,
            body: ResponseBody.nonCopyableMacroExpansionWithDateHeader(#filePath)
        ),
        StaticRoute.post(
            path: ["post"],
            contentType: HTTPMediaTypeApplication.json,
            body: NonCopyableStaticStringWithDateHeader(#"{"bing":"bonged"}"#)
        ),
        StaticRoute.get(
            path: ["bro?what=dude"],
            contentType: HTTPMediaTypeApplication.json,
            body: NonCopyableStaticStringWithDateHeader(#"{"bing":"bonged"}"#)
        ),
        StaticRoute.get(
            path: ["html"],
            contentType: HTTPMediaTypeText.html,
            body: NonCopyableStaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
        ),
        StaticRoute.get(
            path: ["SHOOP"],
            caseSensitive: false,
            contentType: HTTPMediaTypeText.html,
            body: NonCopyableStaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
        ),
        StaticRoute.get(
            version: .v2_0,
            path: ["html2"],
            contentType: HTTPMediaTypeText.html,
            body: NonCopyableStaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
        ),
        StaticRoute.get(
            path: ["json"],
            contentType: HTTPMediaTypeApplication.json,
            body: NonCopyableStaticStringWithDateHeader(#"{"this_outcome_was_inevitable_and_was_your_destiny":true}"#)
            //body: .json(StaticJSONResponse(this_outcome_was_inevitable_and_was_your_destiny: true)) // more work needed to get this working
        ),
        StaticRoute.get(
            path: ["txt"],
            contentType: HTTPMediaTypeText.plain,
            body: NonCopyableStaticStringWithDateHeader("just a regular txt page; t'was your destiny")
        ),
        StaticRoute.get(
            path: ["inlineBytes"],
            contentType: HTTPMediaTypeText.plain,
            body: ResponseBody.nonCopyableInlineBytes([
                .H, .T, .T, .P, .forwardSlash, 49, 46, 49, .space, 50, 48, 48, .carriageReturn, .lineFeed,
                .C, .o, .n, .t, .e, .n, .t, 45, .T, .y, .p, .e, .colon, .space, .t, .e, .x, .t, .forwardSlash, .p, .l, .a, .i, .n, .carriageReturn, .lineFeed,
                .C, .o, .n, .t, .e, .n, .t, 45, .L, .e, .n, .g, .t, .h, .colon, .space, 49, 48, .carriageReturn, .lineFeed, .carriageReturn, .lineFeed,
                33, 34, 35, 36, 37, 38, 39, 40, 41, 42
            ])
        ),
        StaticRoute.get(
            path: ["bytes"],
            contentType: HTTPMediaTypeText.plain,
            body: ResponseBody.nonCopyableBytes([
                .H, .T, .T, .P, .forwardSlash, 49, 46, 49, .space, 50, 48, 48, .carriageReturn, .lineFeed,
                .C, .o, .n, .t, .e, .n, .t, 45, .T, .y, .p, .e, .colon, .space, .t, .e, .x, .t, .forwardSlash, .p, .l, .a, .i, .n, .carriageReturn, .lineFeed,
                .C, .o, .n, .t, .e, .n, .t, 45, .L, .e, .n, .g, .t, .h, .colon, .space, 49, 48, .carriageReturn, .lineFeed, .carriageReturn, .lineFeed,
                33, 34, 35, 36, 37, 38, 39, 40, 41, 42
            ])
        ),
        StaticRoute.get(
            path: ["bytes2"],
            contentType: HTTPMediaTypeText.plain,
            body: ResponseBody.nonCopyableBytes([UInt8]("HTTP/1.1 200\r\nContent-Type: text/plain\r\nContent-Length: 4\r\n\r\nbruh".utf8))
        ),
        StaticRoute.get(
            path: ["bytes3"],
            contentType: HTTPMediaTypeText.plain,
            body: ResponseBody.nonCopyableBytes(Array<UInt8>("HTTP/1.1 200\r\nContent-Type: text/plain\r\nContent-Length: 4\r\n\r\nbruh".utf8))
        ),
        /*StaticRoute.get(
            path: ["error"],
            status: HTTPStandardResponseStatus.badRequest.code,
            contentType: HTTPMediaTypeApplication.json,
            body: .error(CustomError.yipyip)
        ),*/
        DynamicRoute.get( // https://www.techempower.com/benchmarks
            path: ["plaintext"],
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
            handler: { _, response in
                response.setBody(#filePath)
            }
        ),
        DynamicRoute.get(
            path: ["error2"],
            contentType: HTTPMediaTypeText.plain,
            handler: { request, response in
                throw CustomError.yipyip
            }
        ),
        DynamicRoute.get(
            path: ["dynamic"],
            contentType: HTTPMediaTypeText.plain,
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
            contentType: HTTPMediaTypeText.plain,
            handler: { request, response in
                response.setBody("asynced")
                try await Task.sleep(for: .seconds(3))
            }
        ),
        DynamicRoute.get(
            version: .v2_0,
            path: ["dynamic2"],
            contentType: HTTPMediaTypeText.plain,
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
            contentType: HTTPMediaTypeText.plain,
            handler: { request, response in
                response.setBody(response.parameter(at: 0))
            }
        ),
        DynamicRoute.get(
            path: ["anydynamic", "*", "value"],
            contentType: HTTPMediaTypeText.plain,
            handler: { request, response in
                response.setBody(response.parameter(at: 0))
            }
        ),
        DynamicRoute.get(
            path: ["catchall", "**"],
            contentType: HTTPMediaTypeText.plain,
            handler: { request, response in
                var s = "catchall/**;"
                response.yieldParameters { s += "\($0);" }
                response.setBody(s)
            }
        )
    )
}