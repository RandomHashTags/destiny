
#if Logging
import Logging
#endif

/// Default storage that manages services.
public struct Application: Sendable {
    nonisolated(unsafe) public static private(set) var shared:Application! = nil

    public let serviceGroup:DestinyServiceGroup

    #if Logging
    public let logger:Logger
    #endif

    // MARK: Init
    #if Logging
    public init(
        server: some HTTPServerProtocol,
        services: [any DestinyServiceProtocol] = [],
        logger: Logger
    ) {
        var services = services
        services.insert(server, at: 0)
        serviceGroup = DestinyServiceGroup(
            services: services,
            logger: logger
        )
        self.logger = logger
        Self.shared = self
    }
    #else
    public init(
        server: some HTTPServerProtocol,
        services: [any DestinyServiceProtocol] = []
    ) {
        var services = services
        services.insert(server, at: 0)
        serviceGroup = DestinyServiceGroup(
            services: services
        )
        Self.shared = self
    }
    #endif

    public func run() {
        serviceGroup.run()
    }

    public func shutdown() async {
        #if Logging
        logger.info("Application shutting down...")
        #endif

        await serviceGroup.shutdown()

        #if Logging
        logger.info("Application shutdown successfully")
        #endif
    }
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension Application: DestinyServiceProtocol {}

#endif