//
//  main.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

import Destiny
import Logging
import SwiftCompression

let router:Router = #router(
    version: .v1_1,
    supportedCompressionAlgorithms: [],
    middleware: [
        StaticMiddleware(handlesVersions: [.v1_0], appliesHeaders: ["Version":"destiny1.0"]),
        StaticMiddleware(handlesVersions: [.v1_1], appliesHeaders: ["Version":"destiny1.1"], appliesCookies: [HTTPCookie(name: "cookie1", value: "yessir"), HTTPCookie(name: "cookie2", value: "pogchamp")]),
        StaticMiddleware(handlesVersions: [.v2_0], appliesHeaders: ["Version":"destiny2.0"]),
        StaticMiddleware(handlesVersions: [.v3_0], appliesHeaders: ["Version":"destiny3.0"]),
        StaticMiddleware(appliesHeaders: ["Server":"destiny"]),
        StaticMiddleware(handlesMethods: [.get], handlesStatuses: [.notImplemented], handlesContentTypes: [HTTPMediaType.textHtml, HTTPMediaType.applicationJson, HTTPMediaType.textPlain], appliesStatus: .ok),
        StaticMiddleware(handlesMethods: [.get], appliesHeaders: ["You-GET'd":"true"]),
        StaticMiddleware(handlesMethods: [.post], appliesHeaders: ["You-POST'd":"true"]),
        //StaticMiddleware(handlesMethods: [.get], handlesContentTypes: [.javascript], appliesStatus: .badRequest),
        DynamicCORSMiddleware(),
        DynamicDateMiddleware(),
        DynamicMiddleware({ request, response in
            guard request.method == .get else { return }
            #if canImport(FoundationEssentials) || canImport(Foundation)
            response.headers["Womp-Womp"] = UUID().uuidString
            #else
            response.headers["Womp-Womp"] = String(UInt64.random(in: 0..<UInt64.max))
            #endif
        })
    ],
    redirects: [
        .get : [
            .temporaryRedirect : [
                "redirectfrom" : "redirectto"
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
                result: .string("rly dud")
            ),
            DynamicRoute(
                method: .get,
                path: ["HOOPLA"],
                contentType: HTTPMediaType.textPlain,
                handler: { _, response in
                    response.result = .string("RLY DUD")
                }
            )
        ),
    ],
    StaticRoute.get(
        path: ["redirectto"],
        contentType: HTTPMediaType.textHtml,
        result: .staticString(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>You've been redirected from /redirectfrom to here</h1></body></html>"#)
    ),
    StaticRoute.post(
        path: ["post"],
        contentType: HTTPMediaType.applicationJson,
        result: .staticString(#"{"bing":"bonged"}"#)
    ),
    StaticRoute.get(
        path: ["bro?what=dude"],
        contentType: HTTPMediaType.applicationJson,
        result: .staticString(#"{"bing":"bonged"}"#)
    ),
    StaticRoute.get(
        path: ["html"],
        contentType: HTTPMediaType.textHtml,
        result: .staticString(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
    ),
    StaticRoute.get(
        path: ["SHOOP"],
        caseSensitive: false,
        contentType: HTTPMediaType.textHtml,
        result: .staticString(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
    ),
    StaticRoute.get(
        version: .v2_0,
        path: ["html2"],
        contentType: HTTPMediaType.textHtml,
        result: .staticString(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
    ),
    StaticRoute.get(
        path: ["json"],
        contentType: HTTPMediaType.applicationJson,
        result: .staticString(#"{"this_outcome_was_inevitable_and_was_your_destiny":true}"#)
        //result: .json(StaticJSONResponse(this_outcome_was_inevitable_and_was_your_destiny: true)) // more work needed to get this working
    ),
    StaticRoute.get(
        path: ["txt"],
        contentType: HTTPMediaType.textPlain,
        result: .staticString("just a regular txt page; t'was your destiny")
    ),
    StaticRoute.get(
        path: ["bytes"],
        contentType: HTTPMediaType.textPlain,
        result: .bytes([33, 34, 35, 36, 37, 38, 39, 40, 41, 42])
    ),
    StaticRoute.get(
        path: ["bytes2"],
        contentType: HTTPMediaType.textPlain,
        result: .bytes([UInt8]("bruh".utf8))
    ),
    StaticRoute.get(
        path: ["bytes3"],
        contentType: HTTPMediaType.textPlain,
        result: .bytes(Array<UInt8>("bruh".utf8))
    ),
    StaticRoute.get(
        path: ["error"],
        status: .badRequest,
        contentType: HTTPMediaType.applicationJson,
        result: .error(CustomError.yipyip)
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
            response.result = .string("bro")
            //response.result = .string("Host=" + (request.headers["Host"] ?? "nil"))
        }
    ),
    DynamicRoute.get(
        version: .v2_0,
        path: ["dynamic2"],
        contentType: HTTPMediaType.textPlain,
        handler: { request, response in
            #if canImport(FoundationEssentials) || canImport(Foundation)
            response.result = .string(UUID().uuidString)
            #else
            response.result = .string(String(UInt64.random(in: 0..<UInt64.max)))
            #endif
        }
    ),
    DynamicRoute.get(
        path: ["dynamic", ":text"],
        contentType: HTTPMediaType.textPlain,
        handler: { request, response in
            response.result = .string(response.parameters[0])
        }
    ),
    DynamicRoute.get(
        path: ["anydynamic", "*", "value"],
        contentType: HTTPMediaType.textPlain,
        handler: { request, response in
            response.result = .string(response.parameters[0])
        }
    ),
    DynamicRoute.get(
        path: ["catchall", "**"],
        contentType: HTTPMediaType.textPlain,
        handler: { request, response in
            response.result = .string(response.parameters.description)
        }
    )
)
let server:Server<Socket> = try Server<Socket>(
    port: 8080,
    router: router,
    logger: Logger(label: "destiny.http.server"),
    commands: [
        StopCommand.self
    ]
)
let application:Application = Application(
    server: server,
    logger: Logger(label: "destiny.application")
)
try await application.run()

struct StaticJSONResponse : Encodable {
    let this_outcome_was_inevitable_and_was_your_destiny:Bool
}
enum CustomError : Error {
    case yipyip
}