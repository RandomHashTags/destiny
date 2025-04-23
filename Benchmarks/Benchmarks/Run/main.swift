//
//  main.swift
//
//
//  Created by Evan Anderson on 10/19/24.
//

import HTTPTypes
import ServiceLifecycle
import Logging
//import Destiny
//import DestinyUtilities
import Hummingbird
import Vapor

#if os(Linux)
let hostname:String = "192.168.1.174"
#else
let hostname:String = "192.168.1.96"
#endif

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

var environment:Vapor.Environment = .production
try! LoggingSystem.bootstrap(from: &environment)

let logger:Logger = Logger(label: "destiny.application.benchmark")
let application:App = App(services: [
    //destiny_service(port: 8080),
    hummingbird_service(port: 8081),
    vapor_service(port: 8082)
], logger: logger)
try await application.run()


/*
// MARK: Destiny
func destiny_service(port: UInt16) -> Destiny.Application {
    let server_logger:Logger = Logger(label: "destiny.http.server")
    return Destiny.Application(services: [
        Destiny.Server(address: hostname, port: port, maxPendingConnections: 5000, router:
            #router(
                returnType: .staticString,
                version: "HTTP/1.1",
                middleware: [
                    StaticMiddleware(handlesMethods: [.get], handlesContentTypes: [.html])
                ],
                StaticRoute(
                    method: .get,
                    path: "test",
                    status: .ok,
                    contentType: .html,
                    result: .string("<!DOCTYPE html><html><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>")
                )
            ), logger: server_logger
        )
    ], logger: logger)
}*/


// MARK: Hummingbird
func hummingbird_service(port: Int) -> Hummingbird.Application<RouterResponder<BasicRequestContext>> {
    let router:Hummingbird.Router<BasicRequestContext> = Hummingbird.Router()
    let body:Hummingbird.ResponseBody = .init(byteBuffer: ByteBuffer(string: #"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#))
    let headers:HTTPFields = HTTPFields(dictionaryLiteral:
        (.init("You-GET'd")!, "true"),
        (.init("Server")!, "destiny"),
        (.init("Version")!, "destiny1.1"),
        (.contentType, "text/html"),
        (.init("Connection")!, "keep-alive")
    )
    let response:Hummingbird.Response = Response(status: .ok, headers: headers, body: body)
    router.get(RouterPath("html")) { request, _ in
        return response
    }
    router.get(RouterPath("error")) { request, _ in
        throw CustomError.yeet
        return ""
    }
    let app = Hummingbird.Application(router: router, configuration: .init(address: .hostname(hostname, port: port)))
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
    let app:Vapor.Application = Application(environment)
    app.http.server.configuration.port = port
    app.http.server.configuration.hostname = hostname
    app.clients.use(.http)

    let body:Vapor.Response.Body = .init(staticString: #"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
    let headers:HTTPHeaders = HTTPHeaders(dictionaryLiteral:
        ("You-GET'd", "true"),
        ("Server", "destiny"),
        ("Version", "destiny1.1"),
        (HTTPHeaders.Name.contentType.description, "text/html")
    )
    app.get(["html"]) { request in
        // we have to do it this way because its headers get updated every request (probably 'cause its a class)
        return Vapor.Response(status: .ok, version: request.version, headers: headers, body: body)
    }
    app.on(.GET, ["error"]) { request in
        throw CustomError.yeet
        return ""
    }
    return app
}


// MARK: Error
enum CustomError : Error {
    case yeet
}