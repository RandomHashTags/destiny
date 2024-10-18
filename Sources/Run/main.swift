//
//  main.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import Logging
import Destiny

let application:Application = Application(
    services: [
        Server(port: 8080, logger: Logger(label: "destiny.http.server"))
    ],
    logger: Logger(label: "destiny.application")
)
try await application.run()