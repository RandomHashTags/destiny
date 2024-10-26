//
//  main.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import Destiny
import DestinyUtilities
import Logging

let application: Application = Application(
    services: [
        Server(
            threads: 8,
            port: 8080,
            maxPendingConnections: 1000,
            router: #router(
                returnType: .unsafeBufferPointer,
                version: "HTTP/1.1",
                middleware: [
                    StaticMiddleware(
                        appliesToMethods: [.get], appliesToContentTypes: [.html, .json, .text],
                        appliesStatus: .ok
                    )
                ],
                Route(
                    method: .get,
                    path: "html",
                    contentType: .html,
                    charset: "UTF-8",
                    staticResult: .string(
                        "<!DOCTYPE html><html><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"
                    ),
                    dynamicResult: nil
                ),
                Route(
                    method: .get,
                    path: "text",
                    contentType: .text,
                    charset: "UTF-8",
                    staticResult: .string("It Works"),
                    dynamicResult: nil
                ),
                Route(
                    method: .get, path: "json", contentType: .json, charset: "UTF-8",
                    staticResult: .bytes([
                        123, 34, 118, 97, 108, 117, 101, 34, 58, 116, 114, 117, 101, 125,
                    ]),
                    dynamicResult: { req in
                        .string("Help")
                    })
            ),
            logger: Logger(label: "destiny.http.server")
        )
    ],
    logger: Logger(label: "destiny.application")
)
try await application.run()
