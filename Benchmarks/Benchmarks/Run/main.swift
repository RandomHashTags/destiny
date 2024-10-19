//
//  main.swift
//
//
//  Created by Evan Anderson on 10/19/24.
//

import HTTPTypes
import ServiceLifecycle
import Logging
import Destiny
import DestinyUtilities
import Hummingbird
import Vapor


// MARK: App
public struct App : Service {
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


let logger:Logger = Logger(label: "destiny.application.benchmark")
let application:App = App(services: [
    destiny_service(port: 8080),
    hummingbird_service(port: 8081),
    vapor_service(port: 8082)
], logger: logger)
try await application.run()


// MARK: Destiny
func destiny_service(port: UInt16) -> Destiny.Application {
    let server_logger:Logger = Logger(label: "destiny.http.server")
    return Destiny.Application(services: [
        Destiny.Server(port: port, routers: [
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
                    staticResult: .string("<!DOCTYPE><html><body>test</body></html>"),
                    dynamicResult: nil
                )
            )
        ], logger: server_logger)
    ], logger: logger)
}


// MARK: Hummingbird
func hummingbird_service(port: Int) -> Hummingbird.Application<RouterResponder<BasicRequestContext>> {
    struct HeaderMiddleware<Context: RequestContext> : RouterMiddleware {
        func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
            var response = try await next(request, context)
            response.headers[HTTPField.Name.contentType] = "text/html"
            return response
        }
    }

    let router = Hummingbird.Router()
    router.middlewares.add(HeaderMiddleware())
    router.get(RouterPath("test")) { request, _ -> String in
        return "<!DOCTYPE><html><body>test</body></html>"
    }
    let app = Hummingbird.Application(router: router, configuration: .init(address: .hostname("192.168.1.96", port: port)))
    return app
}

// MARK: Vapor
func vapor_service(port: Int) -> Service {
    struct VaporService : Service {
        let app:Vapor.Application
        func run() async throws {
            try await app.execute()
        }
    }
    return VaporService(app: vapor_application(port: port))
}
func vapor_application(port: Int) -> Vapor.Application {
    let app:Vapor.Application = Application(.production)
    app.http.server.configuration.port = port
    app.http.server.configuration.hostname = "192.168.1.96"
    app.clients.use(.http)

    app.on(.GET, ["test"]) { request in
        let body:Vapor.Response.Body = .init(staticString: "<!DOCTYPE><html><body>test</body></html>")
        let headers:HTTPHeaders = HTTPHeaders(dictionaryLiteral: (HTTPHeaders.Name.contentType.description, "text/html"))
        return Vapor.Response(status: .ok, version: request.version, headers: headers, body: body)
    }
    return app
}