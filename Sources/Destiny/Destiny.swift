//
//  Destiny.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import Utilities
import HTTPTypes
import ServiceLifecycle
import Logging

@freestanding(expression)
public macro router<T>(returnType: RouterReturnType, version: String, middleware: [Middleware], _ routes: Route...) -> Router<T> = #externalMacro(module: "Macros", type: "Router")

// MARK: Application
public final class Application : Service {
    public let services:[Service]
    public let logger:Logger

    public init(
        services: [Service] = [],
        logger: Logger
    ) {
        self.services = services
        self.logger = logger
    }
    public func run() async throws {
        let service_group:ServiceGroup = ServiceGroup(configuration: .init(services: services, logger: logger))
        try await service_group.run()
    }
}

func strerror() -> String { String(cString: strerror(errno)) }