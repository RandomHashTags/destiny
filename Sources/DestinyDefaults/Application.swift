//
//  Application.swift
//
//
//  Created by Evan Anderson on 1/2/25.
//

#if canImport(DestinyUtilities)
import DestinyUtilities
#endif

#if canImport(Logging)
import Logging
#endif

#if canImport(ServiceLifecycle)
import ServiceLifecycle
#endif

public struct Application : ApplicationProtocol {
    public static private(set) var shared:Application! = nil

    public let server:ServerProtocol
    public let services:[Service]
    public let logger:Logger

    public init(
        server: ServerProtocol,
        services: [Service] = [],
        logger: Logger
    ) {
        self.server = server
        var services:[Service] = services
        services.insert(server, at: 0)
        self.services = services
        self.logger = logger
        Self.shared = self
    }
    public func run() async throws {
        let group:ServiceGroup = ServiceGroup(configuration: .init(services: services, logger: logger))
        try await group.run()
    }

    public func shutdown() async throws {
        logger.notice("Application shutting down...")
        try await server.shutdown()
        logger.notice("Application shutdown sucessfully")
    }
}