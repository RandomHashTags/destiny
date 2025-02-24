//
//  Application.swift
//
//
//  Created by Evan Anderson on 1/2/25.
//

import DestinyUtilities
import Logging
import ServiceLifecycle

public struct Application : ApplicationProtocol {
    public static private(set) var shared:Application! = nil

    public let serviceGroup:ServiceGroup
    public let logger:Logger

    public init(
        server: ServerProtocol,
        services: [Service] = [],
        logger: Logger
    ) {
        var services:[Service] = services
        services.insert(server, at: 0)
        serviceGroup = ServiceGroup(services: services, logger: logger)
        self.logger = logger
        Self.shared = self
    }
    public func run() async throws {
        try await serviceGroup.run()
    }

    public func shutdown() async throws {
        logger.notice("Application shutting down...")
        await serviceGroup.triggerGracefulShutdown()
        try await gracefulShutdown()
        logger.notice("Application shutdown sucessfully")
    }
}