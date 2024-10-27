//
//  main.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import Logging
import Destiny
import DestinyUtilities

let application:Application = Application(
    services: [
        Server(
            port: 8080,
            maxPendingConnections: 1000,
            router: #router(
                returnType: .unsafeBufferPointer,
                version: "HTTP/1.1",
                middleware: [
                    StaticMiddleware(appliesToMethods: [.get], appliesToContentTypes: [.html], appliesStatus: .ok)
                ],
                StaticRoute(
                    method: .get,
                    path: "test",
                    contentType: .html,
                    charset: "UTF-8",
                    result: .string("<!DOCTYPE html><html><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>")
                )
            ),
            logger: Logger(label: "destiny.http.server")
        )
    ],
    logger: Logger(label: "destiny.application")
)
try await application.run()