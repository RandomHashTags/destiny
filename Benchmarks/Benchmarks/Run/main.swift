
import DestinySwiftSyntax
import TestDestiny
import TestHummingbird
import TestVapor

import HTTPTypes
import Hummingbird
import Logging
import ServiceLifecycle
import Vapor

#if os(Linux)
let hostname = "192.168.1.174"
#else
let hostname = "192.168.1.96"
#endif

// MARK: App
public struct App: Service {
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
        let group = ServiceGroup(configuration: .init(services: services, logger: logger))
        try await group.run()
    }
}

let logger = Logger(label: "destiny.application.benchmark")
let application = App(services: [
    DestinyService(port: 8080),
    hummingbirdService(port: 8081),
    vaporService(port: 8082)
], logger: logger)
try await application.run()


// MARK: Destiny
struct DestinyService: Service {
    let port:UInt16

    init(port: UInt16) {
        self.port = port
    }

    func run() async throws {
        let application = destinyApp(port: port)
        try await application.run()
    }
}
func destinyApp(port: UInt16) -> NonCopyableHTTPServer<DestinyStorage.DeclaredRouter.CompiledHTTPRouter, HTTPSocket> {
    let server = NonCopyableHTTPServer<DestinyStorage.DeclaredRouter.CompiledHTTPRouter, HTTPSocket>(
        address: hostname,
        port: port,
        backlog: 5000,
        router: DestinyStorage.DeclaredRouter.router,
        logger: Logger(label: "destiny.http.server")
    )
    HTTPDateFormat.load(logger: Logger(label: "destiny.application"))
    return server
}


// MARK: Hummingbird
func hummingbirdService(port: Int) -> Hummingbird.Application<RouterResponder<BasicRequestContext>> {
    let router = HummingbirdStorage.router()
    let app = Hummingbird.Application(router: router, configuration: .init(address: .hostname(hostname, port: port)))
    return app
}

// MARK: Vapor
func vaporService(port: Int) -> Service {
    struct VaporService: Service {
        let app:Vapor.Application
        func run() async throws {
            try await app.execute()
        }
    }
    return VaporService(app: vaporApp(port: port))
}
func vaporApp(port: Int) -> Vapor.Application {
    var environment = Vapor.Environment.production
    try! LoggingSystem.bootstrap(from: &environment)
    let app = Vapor.Application(environment)
    app.http.server.configuration.port = port
    app.http.server.configuration.hostname = hostname
    app.clients.use(.http)
    VaporStorage.registerRoutes(app)
    return app
}