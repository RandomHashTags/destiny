
#if canImport(Dispatch)
import Dispatch
#endif

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

#if canImport(SwiftGlibc)
import SwiftGlibc
#endif

import DestinySwiftSyntax
import Logging

LoggingSystem.bootstrap { label in
    var handler = StreamLogHandler.standardOutput(label: label)
    #if DEBUG
    handler.logLevel = .debug
    #else
    handler.logLevel = .error
    #endif
    return handler
}

// MARK: Router
#declareRouter(
    version: .v1_1,
    dynamicNotFoundResponder: nil,
    middleware: [
        StaticMiddleware(
            appliesHeaders: ["Server":"destiny"],
            excludedRoutes: ["plaintext"]
        ),
        StaticMiddleware(
            handlesVersions: [.v1_0],
            appliesHeaders: ["Version":"destiny1.0"]
        ),
        StaticMiddleware(
            handlesVersions: [.v1_1],
            appliesHeaders: ["Version":"destiny1.1", "Connection":"close"],
            appliesCookies: [HTTPCookie(name: "cookie1", value: "yessir"), HTTPCookie(name: "cookie2", value: "pogchamp")],
            excludedRoutes: ["plaintext"]
        ),
        StaticMiddleware(handlesVersions: [.v2_0], appliesHeaders: ["Version":"destiny2.0"]),
        StaticMiddleware(handlesVersions: [.v3_0], appliesHeaders: ["Version":"destiny3.0"]),
        StaticMiddleware(
            handlesMethods: [HTTPStandardRequestMethod.get],
            handlesStatuses: [HTTPStandardResponseStatus.notImplemented.code],
            handlesContentTypes: [HTTPMediaTypeText.html, HTTPMediaTypeApplication.json, HTTPMediaTypeText.plain],
            appliesStatus: HTTPStandardResponseStatus.ok.code,
            excludedRoutes: ["plaintext"]
        ),
        StaticMiddleware(
            handlesMethods: [HTTPStandardRequestMethod.get],
            appliesHeaders: ["You-GET'd":"true"],
            excludedRoutes: ["plaintext"]
        ),
        StaticMiddleware(handlesMethods: [HTTPStandardRequestMethod.post], appliesHeaders: ["You-POST'd":"true"]),
        //StaticMiddleware(handlesMethods: [.get], handlesContentTypes: [.javascript], appliesStatus: .badRequest),
        DynamicCORSMiddleware(),
        DynamicDateMiddleware(),
        DynamicMiddleware({ request, response in
            guard request.isMethod(HTTPStandardRequestMethod.get) else { return }
            #if canImport(FoundationEssentials) || canImport(Foundation)
            response.setHeader(key: "Womp-Womp", value: UUID().uuidString)
            #else
            response.setHeader(key: "Womp-Womp", value: String(UInt64.random(in: 0..<UInt64.max)))
            #endif
        })
    ],
    redirects: [
        StaticRedirectionRoute(method: HTTPStandardRequestMethod.get, from: ["redirectfrom"], to: ["redirectto"])
    ],
    routeGroups: [
        RouteGroup(
            endpoint: "grouped",
            staticMiddleware: [
                StaticMiddleware(appliesHeaders: ["routerGroup":"grouped"])
            ],
            StaticRoute.get(
                path: ["hoopla"],
                contentType: HTTPMediaTypeText.plain,
                body: StringWithDateHeader("rly dud")
            ),
            DynamicRoute.get(
                path: ["HOOPLA"],
                contentType: HTTPMediaTypeText.plain,
                handler: { _, response in
                    response.setBody("RLY DUD")
                }
            )
        ),
    ],
    StaticRoute.get(
        path: ["redirectto"],
        contentType: HTTPMediaTypeText.html,
        body: StaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>You've been redirected from /redirectfrom to here</h1></body></html>"#)
    ),
    StaticRoute.get(
        path: ["stream"],
        contentType: HTTPMediaTypeText.plain,
        body: ResponseBody.streamWithDateHeader(AsyncHTTPChunkDataStream(["1liuesrhbgfler", "test2", "t3", "4"]))
    ),
    StaticRoute.get(
        path: ["expressionMacro"],
        contentType: HTTPMediaTypeText.plain,
        body: ResponseBody.macroExpansion(#filePath)
    ),
    StaticRoute.get(
        path: ["expressionMacroWithDate"],
        contentType: HTTPMediaTypeText.plain,
        body: ResponseBody.macroExpansionWithDateHeader(#filePath)
    ),
    StaticRoute.post(
        path: ["post"],
        contentType: HTTPMediaTypeApplication.json,
        body: StaticStringWithDateHeader(#"{"bing":"bonged"}"#)
    ),
    StaticRoute.get(
        path: ["bro?what=dude"],
        contentType: HTTPMediaTypeApplication.json,
        body: StaticStringWithDateHeader(#"{"bing":"bonged"}"#)
    ),
    StaticRoute.get(
        path: ["html"],
        contentType: HTTPMediaTypeText.html,
        body: StaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
    ),
    StaticRoute.get(
        path: ["SHOOP"],
        caseSensitive: false,
        contentType: HTTPMediaTypeText.html,
        body: StaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
    ),
    StaticRoute.get(
        version: .v2_0,
        path: ["html2"],
        contentType: HTTPMediaTypeText.html,
        body: StaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
    ),
    StaticRoute.get(
        path: ["json"],
        contentType: HTTPMediaTypeApplication.json,
        body: StaticStringWithDateHeader(#"{"this_outcome_was_inevitable_and_was_your_destiny":true}"#)
        //body: .json(StaticJSONResponse(this_outcome_was_inevitable_and_was_your_destiny: true)) // more work needed to get this working
    ),
    StaticRoute.get(
        path: ["txt"],
        contentType: HTTPMediaTypeText.plain,
        body: StaticStringWithDateHeader("just a regular txt page; t'was your destiny")
    ),
    StaticRoute.get(
        path: ["inlineBytes"],
        contentType: HTTPMediaTypeText.plain,
        body: ResponseBody.inlineBytes([33, 34, 35, 36, 37, 38, 39, 40, 41, 42])
    ),
    StaticRoute.get(
        path: ["bytes"],
        contentType: HTTPMediaTypeText.plain,
        body: ResponseBody.bytes([33, 34, 35, 36, 37, 38, 39, 40, 41, 42])
    ),
    StaticRoute.get(
        path: ["bytes2"],
        contentType: HTTPMediaTypeText.plain,
        body: ResponseBody.bytes([UInt8]("bruh".utf8))
    ),
    StaticRoute.get(
        path: ["bytes3"],
        contentType: HTTPMediaTypeText.plain,
        body: ResponseBody.bytes(Array<UInt8>("bruh".utf8))
    ),
    /*StaticRoute.get(
        path: ["error"],
        status: HTTPStandardResponseStatus.badRequest.code,
        contentType: HTTPMediaTypeApplication.json,
        body: .error(CustomError.yipyip)
    ),*/
    DynamicRoute.get( // https://www.techempower.com/benchmarks
        path: ["plaintext"],
        handler: { _, response in
            response.setStatusCode(HTTPStandardResponseStatus.ok.code)
            response.setHeader(key: "Server", value: "Destiny")
            response.setBody("Hello World!")
        }
    ),
    DynamicRoute.get(
        path: ["dynamicExpressionMacro"],
        handler: { _, response in
            response.setBody(#filePath)
        }
    ),
    DynamicRoute.get(
        path: ["error2"],
        contentType: HTTPMediaTypeText.plain,
        handler: { request, response in
            //throw ResponderError.inferred(CustomError.yipyip) // TODO: this breaks compilation | why? | error says the following but doesn't use `any Error`: invalid conversion of thrown error type 'any Error' to 'ResponderError'
        }
    ),
    DynamicRoute.get(
        path: ["dynamic"],
        contentType: HTTPMediaTypeText.plain,
        handler: { request, response in
            response.setBody("Host=" + (request.header(forKey: "Host") ?? "nil"))
        }
    ),
    DynamicRoute.get(
        version: .v2_0,
        path: ["dynamic2"],
        contentType: HTTPMediaTypeText.plain,
        handler: { request, response in
            #if canImport(FoundationEssentials) || canImport(Foundation)
            response.setBody(UUID().uuidString)
            #else
            response.setBody(String(UInt64.random(in: 0..<UInt64.max)))
            #endif
        }
    ),
    DynamicRoute.get(
        path: ["dynamic", ":text"],
        contentType: HTTPMediaTypeText.plain,
        handler: { request, response in
            response.setBody(response.parameter(at: 0))
        }
    ),
    DynamicRoute.get(
        path: ["anydynamic", "*", "value"],
        contentType: HTTPMediaTypeText.plain,
        handler: { request, response in
            response.setBody(response.parameter(at: 0))
        }
    ),
    DynamicRoute.get(
        path: ["catchall", "**"],
        contentType: HTTPMediaTypeText.plain,
        handler: { request, response in
            var s = "catchall/**;"
            response.yieldParameters { s += "\($0);" }
            response.setBody(s)
        }
    )
)

// MARK: Config
let address = processArg(key: "hostname")
var port:UInt16 = 8080
var backlog:Int32 = SOMAXCONN
if let v = processArg(key: "port") {
    port = UInt16(v) ?? port
}
if let v = processArg(key: "backlog") {
    backlog = Int32(v) ?? backlog
}
let reuseAddress = processArg(key: "reuseaddress")?.elementsEqual("true") ?? true
let reusePort = processArg(key: "reuseport")?.elementsEqual("true") ?? true
let noTCPDelay = processArg(key: "tcpnodelay")?.elementsEqual("true") ?? true

let server = HTTPServer<CompiledHTTPRouter, HTTPSocket>(
    address: address,
    port: port,
    backlog: backlog,
    reuseAddress: reuseAddress,
    reusePort: reusePort,
    noTCPDelay: noTCPDelay,
    router: DeclaredRouter.router,
    logger: Logger(label: "destiny.http.server"),
    onLoad: serverOnLoad
)
let application = Application(
    server: server,
    logger: Logger(label: "destiny.application")
)
HTTPDateFormat.load(logger: application.logger)

application.run()

struct StaticJSONResponse: Encodable {
    let this_outcome_was_inevitable_and_was_your_destiny:Bool
}
enum CustomError: Error {
    case yipyip
}

// MARK: On load
@Sendable
func serverOnLoad() {
    #if canImport(Dispatch)
    Task {
        await processCommand()
    }
    #else
    #warning("commands aren't supported")
    #endif
}
@inlinable
func processArg(key: String) -> String? {
    if let v = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--" + key + "=") }) {
        return String(v[v.index(v.startIndex, offsetBy: 3 + key.count)...])
    }
    return nil
}
private func readCommand() async -> String? {
    return await withCheckedContinuation { continuation in
        #if canImport(Dispatch)
        DispatchQueue.global().async {
            continuation.resume(returning: readLine())
        }
        #else
        continuation.resume(returning: nil)
        #endif
    }
}
func processCommand() async {
    if let line = await readCommand() {
        let arguments = line.split(separator: " ")
        switch arguments.first {
        case "stop", "shutdown":
            //do throws(ServiceError) {
                await Application.shared.shutdown()
            //} catch {
            //    Application.shared.logger.warning("Encountered error trying to shutdown application: \(error)")
            //}
            return
        default:
            break
        }
    }
    guard !Task.isCancelled else { return }
    Task {
        await processCommand()
    }
}