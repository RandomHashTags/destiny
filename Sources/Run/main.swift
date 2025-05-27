
#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

import Destiny
import Logging
import SwiftCompression

#declareRouter(
    isCompiled: false,
    version: .v1_1,
    dynamicNotFoundResponder: nil,
    supportedCompressionAlgorithms: [],
    middleware: [
        StaticMiddleware(
            appliesHeaders: ["Server":"destiny"],
            excludedRoutes: ["plaintext"]
        ),
        StaticMiddleware(handlesVersions: [.v1_0], appliesHeaders: ["Version":"destiny1.0"], excludedRoutes: []),
        StaticMiddleware(
            handlesVersions: [.v1_1],
            appliesHeaders: ["Version":"destiny1.1", "Connection":"close"],
            appliesCookies: [HTTPCookie(name: "cookie1", value: "yessir"), HTTPCookie(name: "cookie2", value: "pogchamp")],
            excludedRoutes: ["plaintext"]
        ),
        StaticMiddleware(handlesVersions: [.v2_0], appliesHeaders: ["Version":"destiny2.0"]),
        StaticMiddleware(handlesVersions: [.v3_0], appliesHeaders: ["Version":"destiny3.0"]),
        StaticMiddleware(
            handlesMethods: [.get],
            handlesStatuses: [HTTPResponseStatus.notImplemented.code],
            handlesContentTypes: [HTTPMediaType.textHtml, HTTPMediaType.applicationJson, HTTPMediaType.textPlain],
            appliesStatus: HTTPResponseStatus.ok.code,
            excludedRoutes: ["plaintext"]
        ),
        StaticMiddleware(
            handlesMethods: [.get],
            appliesHeaders: ["You-GET'd":"true"],
            excludedRoutes: ["plaintext"]
        ),
        StaticMiddleware(handlesMethods: [.post], appliesHeaders: ["You-POST'd":"true"]),
        //StaticMiddleware(handlesMethods: [.get], handlesContentTypes: [.javascript], appliesStatus: .badRequest),
        DynamicCORSMiddleware(),
        DynamicDateMiddleware(),
        /*DynamicMiddleware({ request, response in
            guard request.isMethod(HTTPRequestMethod.get) else { return }
            #if canImport(FoundationEssentials) || canImport(Foundation)
            response.setHeader(key: "Womp-Womp", value: UUID().uuidString)
            #else
            response.setHeader(key: "Womp-Womp", value: String(UInt64.random(in: 0..<UInt64.max)))
            #endif
        })*/
    ],
    redirects: [
        .get: [
            HTTPResponseStatus.temporaryRedirect.code: [
                "redirectfrom": "redirectto"
            ]
        ]
    ],
    routerGroups: [
        RouterGroup(
            endpoint: "grouped",
            staticMiddleware: [
                StaticMiddleware(appliesHeaders: ["routerGroup":"grouped"])
            ],
            StaticRoute(
                method: .get,
                path: ["hoopla"],
                contentType: HTTPMediaType.textPlain,
                body: ResponseBody.stringWithDateHeader("rly dud")
            ),
            DynamicRoute(
                method: .get,
                path: ["HOOPLA"],
                contentType: HTTPMediaType.textPlain,
                handler: { _, response in
                    response.setBody("RLY DUD")
                }
            )
        ),
    ],
    StaticRoute.get(
        path: ["redirectto"],
        contentType: HTTPMediaType.textHtml,
        body: ResponseBody.stringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>You've been redirected from /redirectfrom to here</h1></body></html>"#)
    ),
    StaticRoute.get(
        path: ["expressionMacro"],
        contentType: HTTPMediaType.textPlain,
        body: ResponseBody.macroExpansion(#filePath)
    ),
    StaticRoute.get(
        path: ["expressionMacroWithDate"],
        contentType: HTTPMediaType.textPlain,
        body: ResponseBody.macroExpansionWithDateHeader(#filePath)
    ),
    StaticRoute.post(
        path: ["post"],
        contentType: HTTPMediaType.applicationJson,
        body: ResponseBody.stringWithDateHeader(#"{"bing":"bonged"}"#)
    ),
    StaticRoute.get(
        path: ["bro?what=dude"],
        contentType: HTTPMediaType.applicationJson,
        body: ResponseBody.stringWithDateHeader(#"{"bing":"bonged"}"#)
    ),
    StaticRoute.get(
        path: ["html"],
        contentType: HTTPMediaType.textHtml,
        body: ResponseBody.stringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
    ),
    StaticRoute.get(
        path: ["SHOOP"],
        caseSensitive: false,
        contentType: HTTPMediaType.textHtml,
        body: ResponseBody.stringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
    ),
    StaticRoute.get(
        version: .v2_0,
        path: ["html2"],
        contentType: HTTPMediaType.textHtml,
        body: ResponseBody.stringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
    ),
    StaticRoute.get(
        path: ["json"],
        contentType: HTTPMediaType.applicationJson,
        body: ResponseBody.stringWithDateHeader(#"{"this_outcome_was_inevitable_and_was_your_destiny":true}"#)
        //body: .json(StaticJSONResponse(this_outcome_was_inevitable_and_was_your_destiny: true)) // more work needed to get this working
    ),
    StaticRoute.get(
        path: ["txt"],
        contentType: HTTPMediaType.textPlain,
        body: ResponseBody.stringWithDateHeader("just a regular txt page; t'was your destiny")
    ),
    StaticRoute.get(
        path: ["bytes"],
        contentType: HTTPMediaType.textPlain,
        body: ResponseBody.bytes([33, 34, 35, 36, 37, 38, 39, 40, 41, 42])
    ),
    StaticRoute.get(
        path: ["bytes2"],
        contentType: HTTPMediaType.textPlain,
        body: ResponseBody.bytes([UInt8]("bruh".utf8))
    ),
    StaticRoute.get(
        path: ["bytes3"],
        contentType: HTTPMediaType.textPlain,
        body: ResponseBody.bytes(Array<UInt8>("bruh".utf8))
    ),
    /*StaticRoute.get(
        path: ["error"],
        status: HTTPResponseStatus.badRequest.code,
        contentType: HTTPMediaType.applicationJson,
        body: .error(CustomError.yipyip)
    ),*/
    DynamicRoute.get( // https://www.techempower.com/benchmarks
        path: ["plaintext"],
        handler: { _, response in
            response.setStatus(HTTPResponseStatus.ok)
            response.setHeader(key: "Server", value: "Destiny")
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
        contentType: HTTPMediaType.textPlain,
        handler: { request, response in
            throw CustomError.yipyip
        }
    ),
    DynamicRoute.get(
        path: ["dynamic"],
        contentType: HTTPMediaType.textPlain,
        handler: { request, response in
            response.setBody("bro")
            //response.body = .string("Host=" + (request.headers["Host"] ?? "nil"))
        }
    ),
    DynamicRoute.get(
        version: .v2_0,
        path: ["dynamic2"],
        contentType: HTTPMediaType.textPlain,
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
        contentType: HTTPMediaType.textPlain,
        handler: { request, response in
            response.setBody(response.parameter(at: 0))
        }
    ),
    DynamicRoute.get(
        path: ["anydynamic", "*", "value"],
        contentType: HTTPMediaType.textPlain,
        handler: { request, response in
            response.setBody(response.parameter(at: 0))
        }
    ),
    DynamicRoute.get(
        path: ["catchall", "**"],
        contentType: HTTPMediaType.textPlain,
        handler: { request, response in
            response.setBody("catchall/**")
        }
    )
)
let server = try Server<HTTPRouter, Socket>( // compile problem if using `CompiledStaticResponderStorage` ( https://github.com/swiftlang/swift/issues/81650 )
    port: 8080,
    router: router,
    logger: Logger(label: "destiny.http.server"),
    commands: [
        StopCommand.self
    ]
)
let application = Application(
    server: server,
    logger: Logger(label: "destiny.application")
)
Task.detached(priority: .userInitiated) {
    try await HTTPDateFormat.shared.load(logger: application.logger)
}
try await application.run()

struct StaticJSONResponse: Encodable {
    let this_outcome_was_inevitable_and_was_your_destiny:Bool
}
enum CustomError: Error {
    case yipyip
}