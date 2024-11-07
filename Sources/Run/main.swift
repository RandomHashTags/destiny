//
//  main.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import Destiny
import DestinyUtilities
import Foundation
import HTTPTypes
import Logging

let application:Application = Application(
    services: [
        Server<Socket>(
            port: 8080,
            maxPendingConnections: 1000,
            router: #router(
                version: "HTTP/1.1",
                middleware: [
                    StaticMiddleware(handlesMethods: [.get], handlesStatuses: [.notImplemented], handlesContentTypes: [HTTPMediaType.Text.html, HTTPMediaType.Application.json, HTTPMediaType.Text.plain], appliesStatus: .ok),
                    StaticMiddleware(handlesMethods: [.get], appliesHeaders: ["You-GET'd":"true"]),
                    StaticMiddleware(handlesMethods: [.post], appliesHeaders: ["You-POST'd":"true"]),
                    //StaticMiddleware(handlesMethods: [.get], handlesContentTypes: [.javascript], appliesStatus: .badRequest),
                    DynamicMiddleware(
                        async: false,
                        shouldHandleLogic: { request, response in
                            return request.method == .get
                        },
                        handleLogic: { request, response in
                            response.headers["Womp-Womp"] = UUID().uuidString
                        },
                        handleLogicAsync: nil
                    )
                ],
                StaticRoute(
                    method: .get,
                    path: ["html"],
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
                    async: false,
                    method: .get,
                    path: ["dynamic"],
                    contentType: HTTPMediaType.Text.plain,
                    handler: { request, response in
                        response.result = .string(UUID().uuidString)
                    },
                    handlerAsync: nil
                ),
                DynamicRoute(
                    async: false,
                    method: .get,
                    path: ["dynamic", ":text"],
                    contentType: HTTPMediaType.Text.plain,
                    handler: { request, response in
                        response.result = .string(response.parameters["text"] ?? "nil")
                    },
                    handlerAsync: nil
                )
            ),
            logger: Logger(label: "destiny.http.server")
        )
    ],
    logger: Logger(label: "destiny.application")
)
try await application.run()

struct StaticJSONResponse : Encodable {
    let this_outcome_was_inevitable_and_was_your_destiny:Bool
}
enum CustomError : Error {
    case yipyip
}