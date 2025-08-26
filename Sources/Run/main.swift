
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
import TestRouter

LoggingSystem.bootstrap { label in
    var handler = StreamLogHandler.standardOutput(label: label)
    #if DEBUG
    handler.logLevel = .debug
    #else
    handler.logLevel = .error
    #endif
    return handler
}

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
    router: TestRouter.router,
    logger: Logger(label: "destiny.http.server"),
    onLoad: serverOnLoad
)
let application = Application(
    server: server,
    logger: Logger(label: "destiny.application")
)
HTTPDateFormat.load(logger: application.logger)

application.run()

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