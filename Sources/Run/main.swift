//
//  main.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import Destiny
import DestinyUtilities
import HTTPTypes
import Logging

let application:Application = Application(
    services: [
        Server(
            port: 8080,
            maxPendingConnections: 1000,
            router: #router(
                returnType: .staticString,
                version: "HTTP/1.1",
                middleware: [
                    StaticMiddleware(appliesToMethods: [.get], appliesToContentTypes: [.html, .json, .txt], appliesStatus: .ok),
                    //StaticMiddleware(appliesToMethods: [.get], appliesToContentTypes: [.javascript], appliesStatus: .badRequest)
                ],
                StaticRoute(
                    method: .get,
                    path: "html",
                    contentType: .html,
                    result: .string("<!DOCTYPE html><html><head><meta charset=\"UTF-8\"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>")
                ),
                StaticRoute(
                    method: .get,
                    path: "json",
                    contentType: .json,
                    result: .string("{\"this_outcome_was_inevitable_and_was_your_destiny\":true}")
                    //result: .json(StaticJSONResponse(this_outcome_was_inevitable_and_was_your_destiny: true)) // more work needed to get this working
                ),
                StaticRoute(
                    method: .get,
                    path: "txt",
                    contentType: .txt,
                    result: .string("just a regular txt page; t'was your destiny")
                ),
                StaticRoute(
                    method: .get,
                    path: "bytes",
                    contentType: .txt,
                    result: .bytes([33, 34, 35, 36, 37, 38, 39, 40, 41, 42])
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