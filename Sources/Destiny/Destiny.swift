//
//  Destiny.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

@_exported import DestinyDefaults
@_exported import DestinyUtilities
import HTTPTypes
import Logging
import ServiceLifecycle

/// The default macro to create a `Router`.
///
/// - Parameters:
///   - version: The HTTP version this router responds to. All routes not having a version declared adopt this one.
///   - middleware: The middleware this router contains. All middlware is handled in the order they are declared (put your most important middleware first).
///   - routes: The routes that this router contains. All routes are subject to this router's static middleware. Only dynamic routes are subject to dynamic middleware.
@freestanding(expression)
public macro router(
    version: HTTPVersion,
    middleware: [any MiddlewareProtocol],
    _ routes: RouteProtocol...
) -> Router = #externalMacro(module: "DestinyMacros", type: "Router")

// MARK: Application
public struct Application : Service {
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