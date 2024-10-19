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
            routers: [
                #router(
                    returnType: .staticString,
                    version: "HTTP/1.1",
                    middleware: [
                        Middleware(appliesToMethods: [.get], appliesToContentTypes: [.html])
                    ],
                    Route(
                        method: .get,
                        path: "test",
                        status: .ok,
                        contentType: .html,
                        charset: "UTF-8",
                        staticResult: .string("<!DOCTYPE html><html><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"),
                        dynamicResult: nil
                    )
                )
            ],
            logger: Logger(label: "destiny.http.server")
        )
    ],
    logger: Logger(label: "destiny.application")
)
try await application.run()