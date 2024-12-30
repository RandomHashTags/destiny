//
//  main.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import Destiny
import Foundation
import HTTPTypes
import Logging

let server:Server<Socket> = Server<Socket>(
    port: 8080,
    router: #router(
        version: .v1_1,
        supportedCompressionAlgorithms: [],
        middleware: [
            StaticMiddleware(handlesVersions: [.v1_0], appliesHeaders: ["Version":"destiny1.0"]),
            StaticMiddleware(handlesVersions: [.v1_1], appliesHeaders: ["Version":"destiny1.1"]),
            StaticMiddleware(handlesVersions: [.v2_0], appliesHeaders: ["Version":"destiny2.0"]),
            StaticMiddleware(handlesVersions: [.v3_0], appliesHeaders: ["Version":"destiny3.0"]),
            StaticMiddleware(appliesHeaders: ["Server":"destiny"]),
            StaticMiddleware(handlesMethods: [.get], handlesStatuses: [.notImplemented], handlesContentTypes: [HTTPMediaType.Text.html, HTTPMediaType.Application.json, HTTPMediaType.Text.plain], appliesStatus: .ok),
            StaticMiddleware(handlesMethods: [.get], appliesHeaders: ["You-GET'd":"true"]),
            StaticMiddleware(handlesMethods: [.post], appliesHeaders: ["You-POST'd":"true"]),
            //StaticMiddleware(handlesMethods: [.get], handlesContentTypes: [.javascript], appliesStatus: .badRequest),
            DynamicCORSMiddleware(),
            DynamicMiddleware({ request, response in
                guard request.method == .get else { return }
                response.headers["Womp-Womp"] = UUID().uuidString
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
                    contentType: HTTPMediaType.Text.plain,
                    result: .string("rly dud")
                ),
                DynamicRoute(
                    method: .get,
                    path: ["HOOPLA"],
                    contentType: HTTPMediaType.Text.plain,
                    handler: { _, response in
                        response.result = .string("RLY DUD")
                    }
                )
            ),
        ],
        StaticRoute(
            method: .get,
            path: ["redirectto"],
            contentType: HTTPMediaType.Text.html,
            result: .string("<!DOCTYPE html><html><head><meta charset=\"UTF-8\"></head><body><h1>You've been redirected from /redirectfrom to here</h1></body></html>")
        ),
        StaticRoute(
            method: .get,
            path: ["bro?what=dude"],
            contentType: HTTPMediaType.Application.json,
            result: .string("{\"bing\":\"bonged\"}")
        ),
        StaticRoute(
            method: .get,
            path: ["html"],
            contentType: HTTPMediaType.Text.html,
            result: .string("<!DOCTYPE html><html><head><meta charset=\"UTF-8\"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>")
        ),
        StaticRoute(
            version: .v2_0,
            method: .get,
            path: ["html2"],
            contentType: HTTPMediaType.Text.html,
            result: .string("<!DOCTYPE html><html><head><meta charset=\"UTF-8\"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>")
        ),
        StaticRoute(
            method: .get,
            path: ["json"],
            contentType: HTTPMediaType.Application.json,
            result: .string("{\"this_outcome_was_inevitable_and_was_your_destiny\":true}")
            //result: .json(StaticJSONResponse(this_outcome_was_inevitable_and_was_your_destiny: true)) // more work needed to get this working
        ),
        StaticRoute(
            method: .get,
            path: ["txt"],
            contentType: HTTPMediaType.Text.plain,
            result: .string("just a regular txt page; t'was your destiny")
        ),
        StaticRoute(
            returnType: .uint8Array,
            method: .get,
            path: ["bytes"],
            contentType: HTTPMediaType.Text.plain,
            result: .bytes([33, 34, 35, 36, 37, 38, 39, 40, 41, 42])
        ),
        StaticRoute(
            method: .get,
            path: ["error"],
            status: .badRequest,
            contentType: HTTPMediaType.Application.json,
            result: .error(CustomError.yipyip)
        ),
        DynamicRoute(
            method: .get,
            path: ["error2"],
            contentType: HTTPMediaType.Text.plain,
            handler: { request, response in
                throw CustomError.yipyip
            }
        ),
        DynamicRoute(
            method: .get,
            path: ["dynamic"],
            contentType: HTTPMediaType.Text.plain,
            handler: { request, response in
                response.headers["Date"] = Date().formatted()
                response.result = .string("Host=" + (request.headers["Host"] ?? "nil"))
            }
        ),
        DynamicRoute(
            version: .v2_0,
            method: .get,
            path: ["dynamic2"],
            contentType: HTTPMediaType.Text.plain,
            handler: { request, response in
                response.headers["Date"] = Date().formatted()
                response.result = .string(UUID().uuidString)
            }
        ),
        DynamicRoute(
            method: .get,
            path: ["dynamic", ":text"],
            contentType: HTTPMediaType.Text.plain,
            handler: { request, response in
                response.result = .string(response.parameters["text"] ?? "nil")
            }
        )
    ),
    logger: Logger(label: "destiny.http.server")
)
let application:Application = Application(
    services: [server],
    logger: Logger(label: "destiny.application")
)
try await application.run()

struct StaticJSONResponse : Encodable {
    let this_outcome_was_inevitable_and_was_your_destiny:Bool
}
enum CustomError : Error {
    case yipyip
}