
import DestinyBlueprint
import Logging

public struct Application: ApplicationProtocol {
    public static private(set) var shared:Application! = nil

    public let serviceGroup:DestinyServiceGroup
    public let logger:Logger

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
    public func run() {
        serviceGroup.run()
    }

    public func shutdown() async throws {
        logger.notice("Application shutting down...")
        try await serviceGroup.shutdown()
        logger.notice("Application shutdown successfully")
    }
}