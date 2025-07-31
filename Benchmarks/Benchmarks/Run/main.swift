
import HTTPTypes
import ServiceLifecycle
import Logging
import DestinySwiftSyntax
import Hummingbird
import Vapor

#if os(Linux)
let hostname:String = "192.168.1.174"
#else
let hostname:String = "192.168.1.96"
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

var environment = Vapor.Environment.production
try! LoggingSystem.bootstrap(from: &environment)

let logger = Logger(label: "destiny.application.benchmark")
let application = App(services: [
    //DestinyService(port: 8080),
    hummingbird_service(port: 8081),
    vapor_service(port: 8082)
], logger: logger)
try await application.run()


// MARK: Destiny
#declareRouter(
    version: .v1_1,
    middleware: [
        StaticMiddleware(handlesMethods: [HTTPStandardRequestMethod.get], handlesContentTypes: [HTTPMediaTypeText.html], appliesStatus: HTTPStandardResponseStatus.ok.code)
    ],
    redirects: [],
    StaticRoute.get(
        path: ["html"],
        contentType: HTTPMediaTypeText.html,
        body: StringWithDateHeader("<!DOCTYPE html><html><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>")
    )
)

struct DestinyService: Service {
    let port:UInt16

    init(port: UInt16) {
        self.port = port
    }

    func run() async throws {
        let application = destiny_application(port: port)
        Task.detached {
            application.run()
        }
    }
}
func destiny_application(port: UInt16) -> Destiny.Application {
    let server = Destiny.HTTPServer<HTTPRouter, HTTPSocket>(
        address: hostname,
        port: port,
        backlog: 5000,
        router: router,
        logger: Logger(label: "destiny.http.server"),
        onLoad: nil
    )
    let application = Application(
        server: server,
        logger: Logger(label: "destiny.application")
    )
    Task.detached(priority: .userInitiated) {
        try await HTTPDateFormat.shared.load(logger: application.logger)
    }
    return application
}


// MARK: Hummingbird
func hummingbird_service(port: Int) -> Hummingbird.Application<RouterResponder<BasicRequestContext>> {
    let router = Hummingbird.Router()
    let body = Hummingbird.ResponseBody(byteBuffer: ByteBuffer(string: #"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#))
    let headers = Hummingbird.HTTPFields(dictionaryLiteral:
        (.init("Version")!, "destiny1.1"),
        (.init("Server")!, "destiny"),
        (.init("Connection")!, "close"),
        (.init("You-GET'd")!, "true"),
        (.init("Set-Cookie")!, "cookie1=yessir"),
        (.init("Set-Cookie")!, "cookie2=pogchamp"),
        (.contentType, "text/html"),
        (.init("Content-Length")!, "132")
    )
    let response = Hummingbird.Response(status: .ok, headers: headers, body: body)
    router.get("html") { request, _ in
        return response
    }
    router.get("error") { request, _ in
        throw CustomError.yeet
        return ""
    }
    let app = Hummingbird.Application(router: router, configuration: .init(address: .hostname(hostname, port: port)))
    return app
}

// MARK: Vapor
func vapor_service(port: Int) -> Service {
    struct VaporService: Service {
        let app:Vapor.Application
        func run() async throws {
            try await app.execute()
        }
    }
    return VaporService(app: vapor_application(port: port))
}
func vapor_application(port: Int) -> Vapor.Application {
    let app = Vapor.Application(environment)
    app.http.server.configuration.port = port
    app.http.server.configuration.hostname = hostname
    app.clients.use(.http)

    let body = Vapor.Response.Body(staticString: #"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
    let headers = Vapor.HTTPHeaders(dictionaryLiteral:
        ("Version", "destiny1.1"),
        ("Server", "destiny"),
        ("Connection", "close"),
        ("You-GET'd", "true"),
        ("Set-Cookie", "cookie1=yessir"),
        ("Set-Cookie", "cookie2=pogchamp"),
        ("Content-Type", "text/html"),
        ("Content-Length", "132")
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